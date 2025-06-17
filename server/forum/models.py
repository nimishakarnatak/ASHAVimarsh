from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, ForeignKey, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(100), nullable=False)
    is_active = Column(Boolean, default=True)
    is_moderator = Column(Boolean, default=False)
    reputation = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    questions = relationship("Question", back_populates="author")
    answers = relationship("Answer", back_populates="author")
    votes = relationship("Vote", back_populates="user")

class Question(Base):
    __tablename__ = "questions"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False, index=True)
    content = Column(Text, nullable=False)
    tags = Column(JSON, default=list)  # Store tags as JSON array
    author_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    upvotes = Column(Integer, default=0)
    downvotes = Column(Integer, default=0)
    answer_count = Column(Integer, default=0)
    view_count = Column(Integer, default=0)
    is_closed = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    author = relationship("User", back_populates="questions")
    answers = relationship("Answer", back_populates="question", cascade="all, delete-orphan")
    votes = relationship("Vote", back_populates="question")

class Answer(Base):
    __tablename__ = "answers"
    
    id = Column(Integer, primary_key=True, index=True)
    content = Column(Text, nullable=False)
    question_id = Column(Integer, ForeignKey("questions.id"), nullable=False)
    author_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    upvotes = Column(Integer, default=0)
    downvotes = Column(Integer, default=0)
    is_verified = Column(Boolean, default=False)  # Verified by question author or moderator
    is_ai_generated = Column(Boolean, default=False)  # For VertexAI generated answers
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    question = relationship("Question", back_populates="answers")
    author = relationship("User", back_populates="answers")
    votes = relationship("Vote", back_populates="answer")

class Vote(Base):
    __tablename__ = "votes"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    question_id = Column(Integer, ForeignKey("questions.id"), nullable=True)
    answer_id = Column(Integer, ForeignKey("answers.id"), nullable=True)
    vote_type = Column(Integer, nullable=False)  # 1 for upvote, -1 for downvote
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    user = relationship("User", back_populates="votes")
    question = relationship("Question", back_populates="votes")
    answer = relationship("Answer", back_populates="votes")