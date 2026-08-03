#include "GraphicsManager.hpp"
GraphicsManager::GraphicsManager() {
    InitTextures(400, 225);
}

GraphicsManager::~GraphicsManager() {
    glDeleteTextures(1, &outputBufferTexture);
}

void GraphicsManager::InitTextures(int width, int height) {
    glGenTextures(1, &outputBufferTexture);
    glBindTexture(GL_TEXTURE_2D, outputBufferTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, nullptr);
}

void GraphicsManager::RenderObjects(std::shared_ptr<Window> &pWindow, std::unique_ptr<UI> &pUserInterface, std::unique_ptr<ActiveRenderer> &pRenderer, WorldData &pWorld) {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    if (pRenderer->sizeDirty) {
        InitTextures(pRenderer->camParams.imageWidth, pRenderer->camParams.imageHeight);
        pRenderer->sizeDirty = false;
    }

    glBindTexture(GL_TEXTURE_2D, outputBufferTexture);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, pRenderer->camParams.imageWidth, pRenderer->camParams.imageHeight, GL_RGB, GL_UNSIGNED_BYTE, pRenderer->hOutputBuffer);

    pUserInterface->Render((ImTextureID)(intptr_t)outputBufferTexture, pRenderer, pWorld);

    // render everything
    glfwSwapBuffers(pWindow->window);
}