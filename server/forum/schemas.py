from pydantic import BaseModel, EmailStr
from typing import List, Optional
from datetime import datetime
from typing import Optional, Dict, Any

# User schemas
class UserBase(BaseModel):
    username: str
    email: EmailStr

class UserCreate(UserBase):
    password: str

class UserResponse(UserBase):
    id: int
    is_active: bool
    is_moderator: bool
    reputation: int
    created_at: datetime
    
    class Config:
        from_attributes = True

# Question schemas
class QuestionBase(BaseModel):
    title: str
    content: str
    tags: List[str] = []

class QuestionCreate(QuestionBase):
    pass

class QuestionUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None
    tags: Optional[List[str]] = None
    is_closed: Optional[bool] = None

class QuestionResponse(QuestionBase):
    id: int
    author_id: int
    upvotes: int
    downvotes: int
    answer_count: int
    view_count: int
    is_closed: bool
    created_at: datetime
    updated_at: Optional[datetime]
    author: UserResponse
    
    class Config:
        from_attributes = True

# Answer schemas
class AnswerBase(BaseModel):
    content: str

class AnswerCreate(AnswerBase):
    pass

class AnswerUpdate(BaseModel):
    content: Optional[str] = None

class AnswerResponse(AnswerBase):
    id: int
    question_id: int
    author_id: int
    upvotes: int
    downvotes: int
    is_verified: bool
    is_ai_generated: bool
    created_at: datetime
    updated_at: Optional[datetime]
    author: UserResponse
    
    class Config:
        from_attributes = True

# Vote schemas
class VoteCreate(BaseModel):
    question_id: Optional[int] = None
    answer_id: Optional[int] = None
    vote_type: int  # 1 for upvote, -1 for downvote

class VoteResponse(BaseModel):
    id: int
    user_id: int
    question_id: Optional[int]
    answer_id: Optional[int]
    vote_type: int
    created_at: datetime
    
    class Config:
        from_attributes = True

# Search schemas
class SearchResponse(BaseModel):
    query: str
    questions: List[QuestionResponse]
    answers: List[AnswerResponse]
    total_results: int


class RAGQueryRequest(BaseModel):
    query: str
    top_k: Optional[int] = 5

class RAGQueryResponse(BaseModel):
    query: str
    response: str
    sources: Optional[str]
    timestamp: str

class RAGSyncRequest(BaseModel):
    question_ids: Optional[List[int]] = None  # If None, sync all questions
    limit: Optional[int] = 100

class RAGStatsResponse(BaseModel):
    total_files: int
    corpus_name: str
    files: List[Dict[str, Any]]