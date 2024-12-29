# LegalSphere

**Empowering women to navigate the legal system with AI-powered simplicity.**

---

## Problem Statement

Women in India face legal hurdles such as harassment, domestic violence, and workplace discrimination. Complex legal language, societal norms, and cultural stigmas often make understanding and exercising their rights challenging, particularly for women from disadvantaged backgrounds.

---

## Proposed Solution

LegalSphere is an AI-powered chatbot that simplifies legal information using **Retrieval-Augmented Generation (RAG)** technology. Key features include:

- **Multilingual Support**: Accessible to women from diverse linguistic backgrounds.
- **Image Analysis**: Users can upload images related to harassment or security concerns for issue identification and legal guidance.
- **User-Friendly Interface**: Retrieves relevant laws, explains them in simple terms, and connects users to actionable resources.
- **Case Filing Assistance**: Provides step-by-step guidance to help women navigate the legal process and seek justice effectively.

---

## Technical Implementation

1. **Image Upload and Analysis**:
   - Users submit an image related to harassment or violence.
   - The **Gemini Pro** AI model generates a descriptive text summary of the image, focusing on key elements like signs of harassment.

2. **Semantic Understanding**:
   - The generated text is processed using **BERT** to create vector embeddings that capture its semantic meaning.

3. **Legal Information Retrieval**:
   - These embeddings are sent to the backend **GROQ model**, which uses **RAG** to query a JSON-formatted database of legal information.
   - Relevant legal provisions and associated punishments are retrieved and presented as a comprehensive legal summary.

4. **Guidance and Support**:
   - Users receive actionable insights and guidance tailored to their specific scenarios.

---

## Tech Stack

- **Frontend**: ![Flutter](https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png) Flutter and Dart
- **AI Models**: Gemini Pro (Visual Question Answering), GROQ

---

## Architecture

1. User uploads an image or inputs a query.
2. Gemini Pro analyzes the image or text and generates descriptive outputs.
3. BERT processes the data and generates embeddings.
4. GROQ queries the legal database using RAG.
5. Relevant legal information and guidance are displayed to the user.

---

## Download LegalSphere

Experience LegalSphere on your device:

- **Android**: [Download here](#)  
- **iOS**: [Download here](#)

---

## Contributors

| Contributor | Profile |
|-------------|---------|
| ![Siva Prasanth Sivaraj](https://avatars.githubusercontent.com/SivaPrasanthSivaraj?s=100) | [Siva Prasanth Sivaraj](https://github.com/SivaPrasanthSivaraj) |
| ![Suganth](https://avatars.githubusercontent.com/suganth07?s=100) | [Suganth](https://github.com/suganth07) |
| ![Charuvarthan](https://avatars.githubusercontent.com/Charuvarthan?s=100) | [Charuvarthan](https://github.com/Charuvarthan) |

---

## Challenges Faced

- Adapting AI models to work seamlessly within Flutter.
- Establishing robust connections between the frontend and backend.
- Managing API key tools for invoking secure AI functionalities.

---

## Hackathon

A hackathon project leveraging "Gender Tech and Gen AI" to empower women with accessible legal assistance.

