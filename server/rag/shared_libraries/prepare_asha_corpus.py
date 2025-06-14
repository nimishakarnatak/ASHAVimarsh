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
import requests
import tempfile

# Load environment variables from .env file
load_dotenv()

# --- Please fill in your configurations ---
# Retrieve the PROJECT_ID from the environmental variables.
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT")
if not PROJECT_ID:
    raise ValueError(
        "GOOGLE_CLOUD_PROJECT environment variable not set. Please set it in your .env file."
    )
LOCATION = os.getenv("GOOGLE_CLOUD_LOCATION")
if not LOCATION:
    raise ValueError(
        "GOOGLE_CLOUD_LOCATION environment variable not set. Please set it in your .env file."
    )
CORPUS_DISPLAY_NAME = "ASHAVimarsh"
CORPUS_DESCRIPTION = "Corpus containing ASHA Training Module documents"
PDF_URL = "https://nhm.gov.in/images/pdf/communitisation/asha/book-no-1.pdf"
PDF_FILENAME = "book-no-1.pdf"
ENV_FILE_PATH = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".env"))

ASHA_MODULES = [
  'https://nhm.gov.in/images/pdf/communitisation/asha/book-no-1.pdf',
  'https://nhm.gov.in/images/pdf/communitisation/asha/book-no-2.pdf',
  'https://nhm.gov.in/images/pdf/communitisation/asha/book-no-3.pdf',
  'https://nhm.gov.in/images/pdf/communitisation/asha/book-no-4.pdf',
  'https://nhm.gov.in/images/pdf/communitisation/asha/book-no-5.pdf',
  'https://nhm.gov.in/images/pdf/communitisation/asha/book-no-6.pdf',
  'https://nhm.gov.in/images/pdf/communitisation/asha/book-no-7.pdf',
  'https://nhm.gov.in/images/pdf/communitisation/asha/ASHA_Handbook-Mobilizing_for_Action_on_Violence_against_Women_English.pdf',
  'https://nhm.gov.in/images/pdf/communitisation/asha/Reaching_The_Unreached_Brochure_for_ASHA.pdf',
  'https://nhm.gov.in/images/pdf/communitisation/asha/ASHA_Induction_Module_English.pdf',
  'https://nhm.gov.in/images/pdf/communitisation/asha/Notes_for_ASHA_Trainers_Part-1_English.pdf',
  'https://nhm.gov.in/images/pdf/communitisation/asha/Notes_for_ASHA_Trainers_Part-2_English.pdf',
  'https://nhm.gov.in/images/pdf/communitisation/asha/Notes_for_ASHA_Trainers-Mobilizing_for_Action_on_Violence_Against_Women_English.pdf',
  'https://nhm.gov.in/images/pdf/communitisation/asha/Handbook_for_ASHA_Facilitators.pdf'
]

MODULE_TITLES = [
  'Reading Material for ASHA - Book No. 1',
  'Reading Material for ASHA - Book No. 2',
  'Reading Material for ASHA - Book No. 3',
  'Reading Material for ASHA - Book No. 4',
  'Reading Material for ASHA - Book No. 5',
  'ASHA Module 6 - Skills that Save Lives',
  'ASHA Module 7 - Skills that Save Lives',
  'ASHA Handbook-Mobilizing for Action on Violence against Women',
  'Reading Material for ASHA - Reaching The Unreached',
  'Induction Training Modules for ASHAs',
  'Notes for ASHA Trainers Part 1',
  'Notes for ASHA Trainers Part 2',
  'Notes for ASHA Trainers on Violence Against Women',
  'Handbook for ASHA Facilitators'
]


# --- Start of the script ---
def initialize_vertex_ai():
  credentials, project = default()
  vertexai.init(
      project=PROJECT_ID, location=LOCATION, credentials=credentials
  )


def create_or_get_corpus():
  """Creates a new corpus or retrieves an existing one."""
  embedding_model_config = rag.EmbeddingModelConfig(
      publisher_model="publishers/google/models/text-embedding-004"
  )
  existing_corpora = rag.list_corpora()
  corpus = None
  for existing_corpus in existing_corpora:
    if existing_corpus.display_name == CORPUS_DISPLAY_NAME:
      corpus = existing_corpus
      print(f"Found existing corpus with display name '{CORPUS_DISPLAY_NAME}'")
      break
  if corpus is None:
    corpus = rag.create_corpus(
        display_name=CORPUS_DISPLAY_NAME,
        description=CORPUS_DESCRIPTION,
        embedding_model_config=embedding_model_config,
    )
    print(f"Created new corpus with display name '{CORPUS_DISPLAY_NAME}'")
  return corpus


def download_pdf_from_url(url, output_path):
  """Downloads a PDF file from the specified URL."""
  print(f"Downloading PDF from {url}...")
  response = requests.get(url, stream=True)
  response.raise_for_status()  # Raise an exception for HTTP errors
  
  with open(output_path, 'wb') as f:
    for chunk in response.iter_content(chunk_size=8192):
      f.write(chunk)
  
  print(f"PDF downloaded successfully to {output_path}")
  return output_path


def upload_pdf_to_corpus(corpus_name, pdf_path, display_name, description):
  """Uploads a PDF file to the specified corpus."""
  print(f"Uploading {display_name} to corpus...")
  try:
    rag_file = rag.upload_file(
        corpus_name=corpus_name,
        path=pdf_path,
        display_name=display_name,
        description=description,
    )
    print(f"Successfully uploaded {display_name} to corpus")
    return rag_file
  except Exception as e:
    print(f"Error uploading file {display_name}: {e}")
    return None

def update_env_file(corpus_name, env_file_path):
    """Updates the .env file with the corpus name."""
    try:
        set_key(env_file_path, "RAG_CORPUS", corpus_name)
        print(f"Updated RAG_CORPUS in {env_file_path} to {corpus_name}")
    except Exception as e:
        print(f"Error updating .env file: {e}")

def list_corpus_files(corpus_name):
  """Lists files in the specified corpus."""
  files = list(rag.list_files(corpus_name=corpus_name))
  print(f"Total files in corpus: {len(files)}")
  for file in files:
    print(f"File: {file.display_name} - {file.name}")


def main():
  initialize_vertex_ai()
  corpus = create_or_get_corpus()

  # Update the .env file with the corpus name
  update_env_file(corpus.name, ENV_FILE_PATH)

  for file_idx, file_url in enumerate(ASHA_MODULES):
    # filename = f"asha_module_{file_idx + 1}.pdf"
    filename = f"{MODULE_TITLES[file_idx]}.pdf"
    print(f"Processing {filename} from {file_url}...")
    # Create a temporary directory to store the downloaded PDF
    with tempfile.TemporaryDirectory() as temp_dir:
      pdf_path = os.path.join(temp_dir, filename)
      
      # Download the PDF from the URL
      download_pdf_from_url(file_url, pdf_path)
      print(f"Downloading PDF from {file_url} to {pdf_path}...")
      
      # Upload the PDF to the corpus
      upload_pdf_to_corpus(
          corpus_name=corpus.name,
          pdf_path=pdf_path,
          display_name=filename,
          description=f"{MODULE_TITLES[file_idx]}",
      )
    
  # List all files in the corpus
  list_corpus_files(corpus_name=corpus.name)

if __name__ == "__main__":
  main()