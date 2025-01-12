# LegalSphere

<div align="center">
  <img src="https://github.com/user-attachments/assets/466be4b3-42a5-4e03-99c1-d0cc883c8606" alt="LegalSphere Logo" width="300">
  <p><strong>Empowering women to navigate the legal system with AI-powered simplicity.</strong></p>
</div>


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

## Work Flow

![WhatsApp Image 2025-01-12 at 11 21 19_362f4966](https://github.com/user-attachments/assets/3e209dca-870e-48d9-85db-5917fcfbd11a)



# Tech Stack

## Frontend
## Tech Stack

### Frontend
<table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/7aa65597-a88e-49ec-aab8-03f7fa8ffb61" alt="Flutter Logo" width="150">
      <br>
      <b>Flutter</b>
    </td>
  </tr>
</table>

Built using Flutter and Dart for a seamless, cross-platform experience.

---

### AI Models

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/7bcf51b2-aa30-47c2-aa6f-46853ed372ce" alt="Gemini VQA Logo" width="150">
      <br>
      <b>Gemini VQA</b>
      <br>
      Cutting-edge Visual Question Answering (VQA)
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/cb53a019-81ac-433e-819d-d8eeeb6ac00e" alt="Groq Logo" width="150">
      <br>
      <b>Groq Whisper</b>
      <br>
      Speech-to-text engine for real-time transcription and analysis
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/68b0f6c8-bb54-4913-914d-95d777f84334" alt="DeepSeek Logo" width="150">
      <br>
      <b>DeepSeek</b>
      <br>
      Advanced deep learning techniques for knowledge retrieval and synthesis
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/57f56efa-33c9-4274-bd1e-693e9c7a8a4b" alt="DeepGram Logo" width="150">
      <br>
      <b>DeepGram</b>
      <br>
      Text-to-Speech engine for real-time transcription and analysis
    </td>
  </tr>
</table>





---

## Architecture

1. User uploads an image or inputs a query.
2. Gemini Pro analyzes the image or text and generates descriptive outputs.
3. BERT processes the data and generates embeddings.
4. GROQ queries the legal database using RAG.
5. Relevant legal information and guidance are displayed to the user.

---

## Contributors

<table>
  <tr>
    <td align="center">
      <img src="https://avatars.githubusercontent.com/SivaPrasanthSivaraj?s=300" alt="Siva Prasanth Sivaraj" width="150">
      <br>
      <b><a href="https://github.com/SivaPrasanthSivaraj">Siva Prasanth Sivaraj</a></b>
    </td>
    <td align="center">
      <img src="https://avatars.githubusercontent.com/suganth07?s=300" alt="Suganth" width="150">
      <br>
      <b><a href="https://github.com/suganth07">Suganth</a></b>
    </td>
    <td align="center">
      <img src="https://avatars.githubusercontent.com/Charuvarthan?s=300" alt="Charuvarthan" width="150">
      <br>
      <b><a href="https://github.com/Charuvarthan">Charuvarthan</a></b>
    </td>
  </tr>
</table>

---

## Challenges Faced

- Adapting AI models to work seamlessly within Flutter.
- Establishing robust connections between the frontend and backend.
- Managing API key tools for invoking secure AI functionalities.



## Screen Grab

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/1528f77e-cb3b-43e6-b7ca-8032dca28d2f" alt="VQA Screen" width="300">
      <br>
      <b>Image (VQA)</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/d987ae35-1c62-4b94-84c5-36768bf4d61f" alt="Doubts Q&A Screen" width="300">
      <br>
      <b>Doubts (Q&A)</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/66e30af0-9a82-496c-b17c-3a853df684c6" alt="MultiLingual Screen" width="300">
      <br>
      <b>MultiLingual</b>
    </td>
  </tr>
</table>


---

## Hackathon

A hackathon project leveraging "Gender tech and Gen AI" to empower women with accessible legal assistance.

