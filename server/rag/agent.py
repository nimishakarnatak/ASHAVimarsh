import os

from google.adk.agents import Agent
from google.adk.tools import agent_tool
from google.adk.tools.retrieval.vertex_ai_rag_retrieval import VertexAiRagRetrieval
from google.adk.tools import google_search

from vertexai.preview import rag

from dotenv import load_dotenv
from .prompts import return_instructions_root

load_dotenv()

# ask_web = Agent(
#     model='gemini-2.0-flash',
#     name='retireive_web_fallback',
#     description="Agent to answer questions using Google Search.",
#     instruction=
#         'Use this tool to search the web for general health queries when no relevant answer is found in the training modules or forum discussions.'
#     ,
#     tools=[google_search],
# )

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
    similarity_top_k=20,
    vector_distance_threshold=1.0,
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
    similarity_top_k=20,
    vector_distance_threshold=0.4,
)

root_agent = Agent(
    model='gemini-2.5-pro-preview-03-25',
    name='ask_rag_agent',
    instruction=return_instructions_root(),
    description=(
        'This agent answers questions related to ASHA workers training modules and forum discussions. '
        'It uses the training modules first, then the forum, and finally the web if no answer is found.'
    ),
    tools=[
        ask_training_module,
        ask_forum
    ]
)