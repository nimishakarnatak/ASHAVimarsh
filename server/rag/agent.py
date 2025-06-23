import os

from google.adk.agents import Agent
from google.adk.tools.retrieval.vertex_ai_rag_retrieval import VertexAiRagRetrieval
from vertexai.preview import rag

from dotenv import load_dotenv
from .prompts import return_instructions_root

load_dotenv()

ask_training_module = VertexAiRagRetrieval(
    name='asha_training_retrieval',
    description=(
        'Use this tool to retrieve answers for the question from the ASHA workers training modules. Always try to find answers in training modules first before going to forum.'
    ),
    rag_resources=[
        rag.RagResource(
            rag_corpus=os.environ.get("RAG_CORPUS")
        )
    ],
    similarity_top_k=10,
    vector_distance_threshold=0.6,
)

ask_forum = VertexAiRagRetrieval(
    name='retrieve_forum_rag',
    description=(
        'Use this tool to retrieve answers for the question from the Forum corpus in case the answer is not found in the training modules.'
    ),
    rag_resources=[
        rag.RagResource(
            rag_corpus=os.environ.get("FORUM_CORPUS")
        )
    ],
    similarity_top_k=10,
    vector_distance_threshold=0.4,
)

root_agent = Agent(
    model='gemini-2.0-flash-001',
    name='ask_rag_agent',
    instruction=return_instructions_root(),
    tools=[
        ask_training_module,
        ask_forum
    ]
)