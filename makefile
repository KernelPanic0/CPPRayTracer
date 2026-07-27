CXX := g++
NVCC := nvcc
DEBUG ?= 1

ifeq ($(DEBUG),1)
CXXFLAGS := -std=c++20 -g -O0 -fno-omit-frame-pointer -I./includes -I./includes/imgui -I./src/ -MMD -MP
NVCCFLAGS := -std=c++20 -g -O0 -I./includes -I./src/
else
CXXFLAGS := -std=c++20 -O2 -I./includes -I./includes/imgui -I./src/ -MMD -MP
NVCCFLAGS := -std=c++20 -O2 -I./includes -I./src/
endif

LDFLAGS := -lglfw -lGL -ldl -lX11 -lpthread -lXrandr -lXi -lcuda -lcudart

BUILD_DIR := ./build
TARGET := $(BUILD_DIR)/raytracer

SRC := ./src/main.cpp \
    ./includes/glad/glad.c \
    ./src/misc/stb_image.cpp \
    ./src/misc/shader_util.cpp \
    ./src/GLFW/Window.cpp \
    ./src/GLFW/Input.cpp \
	./src/Engine/Engine.cpp \
    ./src/Engine/Graphics/GraphicsManager.cpp \
    ./src/Engine/Graphics/Buffers.cpp \
    ./includes/stb_image_write.c \
    ./src/UI/UI.cpp \
    ./src/UI/ImageViewer.cpp \
    ./includes/imgui/imgui.cpp \
    ./includes/imgui/imgui_draw.cpp \
    ./includes/imgui/imgui_demo.cpp \
    ./includes/imgui/imgui_tables.cpp \
    ./includes/imgui/imgui_widgets.cpp \
    ./includes/imgui/imgui_impl_glfw.cpp \
    ./includes/imgui/imgui_impl_opengl3.cpp

CUDA_SRC := \
    ./src/Engine/Raytracing/Renderer.cu

OBJ := $(SRC:.cpp=.o)
OBJ := $(OBJ:.c=.o)
OBJ := $(patsubst %,$(BUILD_DIR)/%,$(OBJ))

CUDA_OBJ := $(CUDA_SRC:.cu=.o)
CUDA_OBJ := $(patsubst %,$(BUILD_DIR)/%,$(CUDA_OBJ))

all: $(TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(TARGET): $(BUILD_DIR) $(OBJ) $(CUDA_OBJ)
	$(NVCC) $(OBJ) $(CUDA_OBJ) -o $(TARGET) $(LDFLAGS)

$(BUILD_DIR)/%.o: %.cpp | $(BUILD_DIR)
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.cu | $(BUILD_DIR)
	mkdir -p $(dir $@)
	$(NVCC) $(NVCCFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)

run: all
	./$(TARGET)

DEPS := $(OBJ:.o=.d)
-include $(DEPS)

.PHONY: all clean run