from fastapi import FastAPI, HTTPException, Depends, Query, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import or_, desc, asc
from typing import List, Optional
import uvicorn
from datetime import datetime

from database import SessionLocal, engine
from models import Base, Question, Answer, User, Vote
from schemas import (
    QuestionCreate, QuestionResponse, QuestionUpdate,
    AnswerCreate, AnswerResponse, AnswerUpdate,
    UserCreate, UserResponse,
    VoteCreate, VoteResponse,
    SearchResponse
)
from auth import get_current_user, create_access_token, verify_password, get_password_hash

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Q&A Forum API",
    description="A question and answer forum with search functionality",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

security = HTTPBearer()

# Dependency to get database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Authentication endpoints
@app.post("/auth/register", response_model=UserResponse)
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    # Check if user already exists
    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Create new user
    hashed_password = get_password_hash(user.password)
    db_user = User(
        username=user.username,
        email=user.email,
        hashed_password=hashed_password
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    return db_user

@app.post("/auth/login")
def login_user(email: str, password: str, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == email).first()
    if not user or not verify_password(password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    access_token = create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer", "user": user}

# Question endpoints
@app.post("/questions", response_model=QuestionResponse)
def create_question(
    question: QuestionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    db_question = Question(
        title=question.title,
        content=question.content,
        tags=question.tags,
        author_id=current_user.id
    )
    db.add(db_question)
    db.commit()
    db.refresh(db_question)
    return db_question

@app.get("/questions", response_model=List[QuestionResponse])
def get_questions(
    skip: int = 0,
    limit: int = 20,
    sort_by: str = Query("created_at", enum=["created_at", "votes", "answers"]),
    order: str = Query("desc", enum=["asc", "desc"]),
    db: Session = Depends(get_db)
):
    query = db.query(Question)
    
    # Sorting
    if sort_by == "votes":
        if order == "desc":
            query = query.order_by(desc(Question.upvotes - Question.downvotes))
        else:
            query = query.order_by(asc(Question.upvotes - Question.downvotes))
    elif sort_by == "answers":
        if order == "desc":
            query = query.order_by(desc(Question.answer_count))
        else:
            query = query.order_by(asc(Question.answer_count))
    else:  # created_at
        if order == "desc":
            query = query.order_by(desc(Question.created_at))
        else:
            query = query.order_by(asc(Question.created_at))
    
    return query.offset(skip).limit(limit).all()

@app.get("/questions/{question_id}", response_model=QuestionResponse)
def get_question(question_id: int, db: Session = Depends(get_db)):
    question = db.query(Question).filter(Question.id == question_id).first()
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")
    return question

@app.put("/questions/{question_id}", response_model=QuestionResponse)
def update_question(
    question_id: int,
    question_update: QuestionUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    question = db.query(Question).filter(Question.id == question_id).first()
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")
    
    if question.author_id != current_user.id and not current_user.is_moderator:
        raise HTTPException(status_code=403, detail="Not authorized to update this question")
    
    for field, value in question_update.dict(exclude_unset=True).items():
        setattr(question, field, value)
    
    question.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(question)
    return question

@app.delete("/questions/{question_id}")
def delete_question(
    question_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    question = db.query(Question).filter(Question.id == question_id).first()
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")
    
    if question.author_id != current_user.id and not current_user.is_moderator:
        raise HTTPException(status_code=403, detail="Not authorized to delete this question")
    
    db.delete(question)
    db.commit()
    return {"message": "Question deleted successfully"}

# Answer endpoints
@app.post("/questions/{question_id}/answers", response_model=AnswerResponse)
def create_answer(
    question_id: int,
    answer: AnswerCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Check if question exists
    question = db.query(Question).filter(Question.id == question_id).first()
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")
    
    db_answer = Answer(
        content=answer.content,
        question_id=question_id,
        author_id=current_user.id
    )
    db.add(db_answer)
    
    # Update question answer count
    question.answer_count += 1
    
    db.commit()
    db.refresh(db_answer)
    return db_answer

@app.get("/questions/{question_id}/answers", response_model=List[AnswerResponse])
def get_answers(
    question_id: int,
    skip: int = 0,
    limit: int = 20,
    sort_by: str = Query("created_at", enum=["created_at", "votes"]),
    order: str = Query("desc", enum=["asc", "desc"]),
    db: Session = Depends(get_db)
):
    query = db.query(Answer).filter(Answer.question_id == question_id)
    
    # Sorting
    if sort_by == "votes":
        if order == "desc":
            query = query.order_by(desc(Answer.upvotes - Answer.downvotes))
        else:
            query = query.order_by(asc(Answer.upvotes - Answer.downvotes))
    else:  # created_at
        if order == "desc":
            query = query.order_by(desc(Answer.created_at))
        else:
            query = query.order_by(asc(Answer.created_at))
    
    return query.offset(skip).limit(limit).all()

@app.put("/answers/{answer_id}", response_model=AnswerResponse)
def update_answer(
    answer_id: int,
    answer_update: AnswerUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    answer = db.query(Answer).filter(Answer.id == answer_id).first()
    if not answer:
        raise HTTPException(status_code=404, detail="Answer not found")
    
    if answer.author_id != current_user.id and not current_user.is_moderator:
        raise HTTPException(status_code=403, detail="Not authorized to update this answer")
    
    for field, value in answer_update.dict(exclude_unset=True).items():
        setattr(answer, field, value)
    
    answer.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(answer)
    return answer

@app.put("/answers/{answer_id}/verify")
def verify_answer(
    answer_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    answer = db.query(Answer).filter(Answer.id == answer_id).first()
    if not answer:
        raise HTTPException(status_code=404, detail="Answer not found")
    
    # Only question author or moderators can verify answers
    question = db.query(Question).filter(Question.id == answer.question_id).first()
    if question.author_id != current_user.id and not current_user.is_moderator:
        raise HTTPException(status_code=403, detail="Not authorized to verify this answer")
    
    answer.is_verified = not answer.is_verified
    db.commit()
    return {"message": f"Answer {'verified' if answer.is_verified else 'unverified'} successfully"}

# Voting endpoints
@app.post("/vote", response_model=VoteResponse)
def vote(
    vote: VoteCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Check if user already voted
    existing_vote = db.query(Vote).filter(
        Vote.user_id == current_user.id,
        Vote.question_id == vote.question_id,
        Vote.answer_id == vote.answer_id
    ).first()
    
    if existing_vote:
        # Update existing vote
        old_vote_type = existing_vote.vote_type
        existing_vote.vote_type = vote.vote_type
        db.commit()
        
        # Update vote counts
        if vote.question_id:
            question = db.query(Question).filter(Question.id == vote.question_id).first()
            if old_vote_type == 1:  # was upvote
                question.upvotes -= 1
            elif old_vote_type == -1:  # was downvote
                question.downvotes -= 1
            
            if vote.vote_type == 1:  # new upvote
                question.upvotes += 1
            elif vote.vote_type == -1:  # new downvote
                question.downvotes += 1
        
        if vote.answer_id:
            answer = db.query(Answer).filter(Answer.id == vote.answer_id).first()
            if old_vote_type == 1:
                answer.upvotes -= 1
            elif old_vote_type == -1:
                answer.downvotes -= 1
            
            if vote.vote_type == 1:
                answer.upvotes += 1
            elif vote.vote_type == -1:
                answer.downvotes += 1
        
        db.commit()
        return existing_vote
    else:
        # Create new vote
        db_vote = Vote(
            user_id=current_user.id,
            question_id=vote.question_id,
            answer_id=vote.answer_id,
            vote_type=vote.vote_type
        )
        db.add(db_vote)
        
        # Update vote counts
        if vote.question_id:
            question = db.query(Question).filter(Question.id == vote.question_id).first()
            if vote.vote_type == 1:
                question.upvotes += 1
            elif vote.vote_type == -1:
                question.downvotes += 1
        
        if vote.answer_id:
            answer = db.query(Answer).filter(Answer.id == vote.answer_id).first()
            if vote.vote_type == 1:
                answer.upvotes += 1
            elif vote.vote_type == -1:
                answer.downvotes += 1
        
        db.commit()
        db.refresh(db_vote)
        return db_vote

# Search endpoint
@app.get("/search", response_model=SearchResponse)
def search(
    q: str = Query(..., min_length=1, description="Search query"),
    skip: int = 0,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    # Search in questions
    questions = db.query(Question).filter(
        or_(
            Question.title.contains(q),
            Question.content.contains(q),
            Question.tags.contains(q)
        )
    ).offset(skip).limit(limit).all()
    
    # Search in answers
    answers = db.query(Answer).filter(
        Answer.content.contains(q)
    ).offset(skip).limit(limit).all()
    
    return SearchResponse(
        query=q,
        questions=questions,
        answers=answers,
        total_results=len(questions) + len(answers)
    )

# Health check
@app.get("/health")
def health_check():
    return {"status": "healthy", "timestamp": datetime.utcnow()}

# VertexAI RAG integration placeholder
@app.post("/ai/generate-answer")
async def generate_ai_answer(
    question_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Placeholder for VertexAI RAG integration
    This will generate AI-powered answers based on existing Q&A data
    """
    question = db.query(Question).filter(Question.id == question_id).first()
    if not question:
        raise HTTPException(status_code=404, detail="Question not found")
    
    # TODO: Integrate with VertexAI RAG API
    # This is where you'll implement the RAG functionality
    
    return {
        "message": "AI answer generation will be implemented with VertexAI RAG",
        "question_id": question_id,
        "question_title": question.title
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)