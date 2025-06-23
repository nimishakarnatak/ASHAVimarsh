# 🏥 ASHA Vimarsh

<p align="center">
    <img src="https://i.imgur.com/waxVImv.png" alt="Image">
</p>

[Nimisha Karnatak](https://www.nimishakarnatak.com/)<sup>1</sup>, [Shivang Chopra](https://shivangchopra11.github.io/)<sup>2</sup>  <br>
**<sup>1</sup>University of Oxford, <sup>2</sup>Georgia Institute of Technology**

## Inspiration

> #### **22 minutes. That's how often India loses a mother!**

Based on India's Sample Registration System, **24,000 mothers** die annually from pregnancy complications. That is **one preventable death every 22 minutes**. Behind each statistic is a family shattered, a baby motherless, a community grieving.

Yet across India's villages, a quiet force is working to change this narrative. Since 2005, India's **ASHA (Accredited Social Health Activist)** program has mobilized over **1 million women** across **600,000 villages**. These frontline workers are often the first and sometimes only point of contact for maternal and perinatal care in rural communities. They monitor pregnancies, counsel families, and respond to emergencies, all while navigating complex health programs with remarkable dedication despite limited support.

We first encountered this system during our time at Microsoft Research India, where Nimisha spent two years studying healthcare delivery in resource-constrained settings and Shivang was looking into making technologies accesible to various demographics. Through extensive fieldwork, we witnessed both the deep expertise ASHAs bring to their communities and the structural challenges they face daily such as outdated training materials, fragmented paper records, and virtually no clinical decision support when it matters most.

### 🤝 **The Key Insight**
What struck us most was how ASHAs naturally turn to each other for guidance. Their strength lies in their community roots:

- **From the community** - They understand local contexts
- **Chosen by the community** - They have local trust and credibility
- **Serve the community** - They work alongside fellow ASHAs

Every ASHA knows her most valuable resource is the **collective wisdom of other ASHAs**. When faced with uncertainty, they meet or call each other, share experiences through WhatsApp, and learn from each other's successes and mistakes.

### ❓ **The Crucial Question**
> *What if this peer knowledge could be searchable, archivable, and enriched through AI?*

Based on this foundational insight, we developed **ASHA Vimarsh**, a contextual AI system that transforms distributed peer knowledge into centralized, accessible intelligence for decision-making.

---

## What it does
ASHA Vimarsh is a contextual AI system designed to support community health workers, specifically ASHAs, in delivering timely, informed, and trusted maternal care.
Unlike generic health chatbots, the system is built to augment real-world decision-making in low-resource settings. It combines verified medical protocols with peer-driven insights to assist ASHAs in identifying risks, validating concerns, and acting with greater confidence.

Key features of ASHA Vimarsh include:

#### Built on Retrieval from Government Maternal Health Modules
The system retrieves verified information from official maternal health guidelines using a Retrieval-Augmented Generation (RAG) pipeline. This ensures that responses are grounded in medically reliable, policy-aligned sources without requiring direct fine-tuning on sensitive health data.

#### Contextual Peer Forum Integration
A dedicated forum allows ASHAs to share firsthand experiences and raise questions. Validated responses from senior ASHAs and Auxiliary Nurse Midwives (ANMs) are integrated into the system’s memory, enriching it with contextual, field-tested knowledge.

#### Traceability and Source Attribution
Each AI-generated response includes a clear reference to its source, whether from a government document or a peer forum post. This promotes transparency and reinforces community trust in the AI’s recommendations.

#### Report Upload and Analysis
ASHAs can upload structured reports (such as blood pressure logs). The system parses this data to detect symptom trends and potential risks, enabling proactive and pattern-aware care decisions.


###  **Key Features**

####  **Orchestrated AI Architecture**
- **4 Specialized Sub-Agents** for different knowledge domains:
  - Training Module Agent
  - Community Forum Agent  
  - Web Search Agent
  - Diagnostic Analysis Agent

####  **Hierarchical Information Prioritization**
```
                 Official Training Content
                      (Authoritative)
                            ↓
                      Community Insights
                      (Experiential)
                            ↓
                    Current Research
                     (Supplementary)
```

#### **Rich Response System**
- **Citation-Rich Answers** with specific references
- **Related Question Suggestions** for deeper learning
- **Diagnostic Report Analysis** for better patient communication

---

##  How we built it

###  **Architecture Design**
We built ASHA Vimarsh using a sophisticated **multi-agent orchestration system** that mirrors how ASHAs naturally seek and synthesize information:

### **Specialized Sub-Agents**

#### **Training Module Agent** 
- **Expertise**: Official ASHA protocols and procedures
- **Tool**: VertexAI RAG system with training materials
- **Output**: Authoritative, protocol-based guidance

#### **Forum Agent**   
- **Expertise**: Community-generated content and peer experiences
- **Tool**: Forum discussion retrieval system
- **Output**: Field-tested, community-validated insights

#### **Web Search Agent** 
- **Expertise**: Current medical research and guidelines
- **Sources**: WHO, government health departments, medical journals
- **Output**: Up-to-date medical information with credibility verification

#### **Diagnostic Agent** 
- **Expertise**: Medical report analysis for educational purposes
- **Function**: Breaks down complex medical terminology
- **Safety**: Always includes professional consultation disclaimers


###  **Data Integration Pipeline**
1. **Training Materials** → Digitized & indexed → Searchable embeddings
2. **Forum Discussions** → Curated Q&A content → Community insights
3. **Medical Research** → Real-time web search → Current guidelines
4. **Diagnostic Reports** → Document analysis → Educational interpretation

## Challenges we ran into

**Technical Challenges:**
- **Multi-Source Information Synthesis**: Balancing different types of knowledge sources (official training vs. community experience vs. current research) while maintaining accuracy and relevance
- **Language and Context Barriers**: Ensuring the AI understands the specific terminology and context of rural Indian healthcare delivery

**Domain-Specific Challenges:**
- **Cultural Context Integration**: Understanding the nuanced ways ASHAs communicate and seek help within their community structures
- **Quality Assurance**: Developing validation mechanisms to ensure AI responses align with official health protocols

**User Experience Challenges:**
- **Simplicity vs. Comprehensiveness**: Balancing detailed, helpful responses with the practical constraints of ASHAs working in field conditions
- **Citation Management**: Creating citation systems that are informative but not overwhelming for users who may have limited technical literacy
- **Response Relevance**: Fine-tuning the system to understand implicit context in ASHA queries and provide appropriately targeted responses
