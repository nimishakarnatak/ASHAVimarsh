# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from google.auth import default
import vertexai
from vertexai.preview import rag
import os
from dotenv import load_dotenv, set_key
import tempfile
import json
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, ForeignKey, JSON
from sqlalchemy.orm import relationship, declarative_base
from sqlalchemy.sql import func

from models import User, Question, Answer  # Import your SQLAlchemy models

# Load environment variables from .env file
load_dotenv()


# --- Configuration ---
# Retrieve configuration from environment variables
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT")
if not PROJECT_ID:
    raise ValueError("GOOGLE_CLOUD_PROJECT environment variable not set. Please set it in your .env file.")

LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION")
if not LOCATION:
    raise ValueError("GOOGLE_CLOUD_LOCATION environment variable not set. Please set it in your .env file.")

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise ValueError("DATABASE_URL environment variable not set. Please set it in your .env file.")

# Forum corpus configuration
FORUM_CORPUS_DISPLAY_NAME = "ForumQA"
FORUM_CORPUS_DESCRIPTION = "Corpus containing forum questions and answers"
ENV_FILE_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".env"))

# Filtering criteria
MIN_UPVOTES = int(os.getenv("MIN_UPVOTES", "0"))  # Minimum upvotes for questions/answers to include
INCLUDE_VERIFIED_ONLY = os.getenv("INCLUDE_VERIFIED_ONLY", "false").lower() == "true"
EXCLUDE_AI_GENERATED = os.getenv("EXCLUDE_AI_GENERATED", "true").lower() == "true"

def initialize_vertex_ai():
    """Initialize Vertex AI with credentials and project settings."""
    credentials, project = default()
    vertexai.init(
        project=PROJECT_ID, location=LOCATION, credentials=credentials
    )
    print(f"Initialized Vertex AI for project: {PROJECT_ID}")

def create_database_connection():
    """Create database connection and session."""
    engine = create_engine(DATABASE_URL)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    return SessionLocal()

def create_or_get_forum_corpus():
    """Creates a new forum corpus or retrieves an existing one."""
    embedding_model_config = rag.EmbeddingModelConfig(
        publisher_model="publishers/google/models/text-embedding-004"
    )
    
    existing_corpora = rag.list_corpora()
    corpus = None
    
    for existing_corpus in existing_corpora:
        if existing_corpus.display_name == FORUM_CORPUS_DISPLAY_NAME:
            corpus = existing_corpus
            print(f"Found existing corpus with display name '{FORUM_CORPUS_DISPLAY_NAME}'")
            break
    
    if corpus is None:
        corpus = rag.create_corpus(
            display_name=FORUM_CORPUS_DISPLAY_NAME,
            description=FORUM_CORPUS_DESCRIPTION,
            embedding_model_config=embedding_model_config,
        )
        print(f"Created new corpus with display name '{FORUM_CORPUS_DISPLAY_NAME}'")
    
    return corpus

def fetch_qa_data(db_session):
    """Fetch questions and answers from the database with filtering."""
    print("Fetching questions and answers from database...")
    
    # Build query with filters
    query = db_session.query(Question).join(User, Question.author_id == User.id)
    
    # Apply filters
    if MIN_UPVOTES > 0:
        query = query.filter(Question.upvotes >= MIN_UPVOTES)
    
    # Don't include closed questions
    query = query.filter(Question.is_closed == False)
    
    questions = query.all()
    
    qa_data = []
    
    for question in questions:
        # Get answers for this question
        answer_query = db_session.query(Answer).filter(Answer.question_id == question.id)
        
        # Apply answer filters
        if MIN_UPVOTES > 0:
            answer_query = answer_query.filter(Answer.upvotes >= MIN_UPVOTES)
        
        if INCLUDE_VERIFIED_ONLY:
            answer_query = answer_query.filter(Answer.is_verified == True)
        
        if EXCLUDE_AI_GENERATED:
            answer_query = answer_query.filter(Answer.is_ai_generated == False)
        
        answers = answer_query.all()
        
        # Only include questions that have at least one answer meeting criteria
        if answers:
            qa_item = {
                'question_id': question.id,
                'question_title': question.title,
                'question_content': question.content,
                'question_tags': question.tags or [],
                'question_upvotes': question.upvotes,
                'question_author': question.author.username,
                'question_created_at': question.created_at.isoformat() if question.created_at else None,
                'answers': []
            }
            
            for answer in answers:
                qa_item['answers'].append({
                    'answer_id': answer.id,
                    'answer_content': answer.content,
                    'answer_upvotes': answer.upvotes,
                    'answer_author': answer.author.username,
                    'is_verified': answer.is_verified,
                    'answer_created_at': answer.created_at.isoformat() if answer.created_at else None
                })
            
            qa_data.append(qa_item)
    
    print(f"Fetched {len(qa_data)} questions with answers")
    return qa_data

def format_qa_as_text(qa_item):
    """Format a question-answer pair as structured text for RAG."""
    text = f"QUESTION: {qa_item['question_title']}\n\n"
    text += f"DETAILS: {qa_item['question_content']}\n\n"
    
    if qa_item['question_tags']:
        text += f"TAGS: {', '.join(qa_item['question_tags'])}\n\n"
    
    text += "ANSWERS:\n\n"
    
    # Sort answers by upvotes (descending) and verified status
    sorted_answers = sorted(
        qa_item['answers'], 
        key=lambda x: (x['is_verified'], x['answer_upvotes']), 
        reverse=True
    )
    
    for i, answer in enumerate(sorted_answers, 1):
        verified_marker = " ✓ VERIFIED" if answer['is_verified'] else ""
        text += f"Answer {i}{verified_marker}:\n"
        text += f"{answer['answer_content']}\n"
        text += f"(Upvotes: {answer['answer_upvotes']}, Author: {answer['answer_author']})\n\n"
    
    # Add metadata
    text += f"---\n"
    text += f"Question ID: {qa_item['question_id']}\n"
    text += f"Question Author: {qa_item['question_author']}\n"
    text += f"Question Upvotes: {qa_item['question_upvotes']}\n"
    text += f"Created: {qa_item['question_created_at']}\n"
    
    return text

def upload_qa_to_corpus(corpus_name, qa_data):
    """Upload question-answer pairs to the corpus as text files."""
    print(f"Uploading {len(qa_data)} Q&A pairs to corpus...")
    
    uploaded_count = 0
    failed_count = 0
    
    for qa_item in qa_data:
        try:
            # Format the Q&A as text
            qa_text = format_qa_as_text(qa_item)
            
            # Create a temporary text file
            with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False, encoding='utf-8') as temp_file:
                temp_file.write(qa_text)
                temp_file_path = temp_file.name
            
            try:
                # Create display name and description
                display_name = f"Forum: Q{qa_item['question_id']}: {qa_item['question_title'][:50]}..."
                description = f"Forum Q&A - Question ID: {qa_item['question_id']}, Answers: {len(qa_item['answers'])}"
                
                # Upload to corpus
                rag_file = rag.upload_file(
                    corpus_name=corpus_name,
                    path=temp_file_path,
                    display_name=display_name,
                    description=description,
                )
                
                uploaded_count += 1
                if uploaded_count % 10 == 0:
                    print(f"Uploaded {uploaded_count} Q&A pairs...")
                
            finally:
                # Clean up temporary file
                os.unlink(temp_file_path)
                
        except Exception as e:
            print(f"Error uploading Q&A {qa_item['question_id']}: {e}")
            failed_count += 1
            continue
    
    print(f"Upload complete. Successfully uploaded: {uploaded_count}, Failed: {failed_count}")
    return uploaded_count, failed_count

def update_env_file(corpus_name, env_file_path):
    """Updates the .env file with the forum corpus name."""
    try:
        set_key(env_file_path, "FORUM_RAG_CORPUS", corpus_name)
        print(f"Updated FORUM_RAG_CORPUS in {env_file_path} to {corpus_name}")
    except Exception as e:
        print(f"Error updating .env file: {e}")

def list_corpus_files(corpus_name):
    """Lists files in the specified corpus."""
    files = list(rag.list_files(corpus_name=corpus_name))
    print(f"Total files in corpus: {len(files)}")
    
    # Show first few files as examples
    for i, file in enumerate(files[:5]):
        print(f"File {i+1}: {file.display_name}")
    
    if len(files) > 5:
        print(f"... and {len(files) - 5} more files")

def main():
    """Main execution function."""
    print("Starting Forum Q&A to Vertex AI RAG upload process...")
    
    # Initialize services
    initialize_vertex_ai()
    db_session = create_database_connection()
    
    try:
        # Create or get corpus
        corpus = create_or_get_forum_corpus()
        
        # Update environment file
        update_env_file(corpus.name, ENV_FILE_PATH)
        
        # Fetch Q&A data from database
        qa_data = fetch_qa_data(db_session)
        
        if not qa_data:
            print("No Q&A data found matching the criteria. Exiting.")
            return
        
        # Upload to corpus
        uploaded_count, failed_count = upload_qa_to_corpus(corpus.name, qa_data)
        
        # List corpus contents
        list_corpus_files(corpus_name=corpus.name)
        
        print(f"\nProcess completed successfully!")
        print(f"- Total Q&A pairs processed: {len(qa_data)}")
        print(f"- Successfully uploaded: {uploaded_count}")
        print(f"- Failed uploads: {failed_count}")
        print(f"- Corpus name: {corpus.name}")
        
    except Exception as e:
        print(f"Error in main process: {e}")
        raise
    finally:
        db_session.close()

if __name__ == "__main__":
    main()