CXX := g++
GPU_CC := $(shell command -v hipcc 2>/dev/null || echo /opt/rocm/bin/hipcc)
BACKEND ?= amd
DEBUG ?= 1

CUDA_SRC := ./src/Engine/Raytracing/Renderer.cu

ifeq ($(BACKEND),amd)
    export HIP_PLATFORM := amd
    GPU_ARCH := --offload-arch=gfx1031
    GPU_OPT := -Ofast
    CUDA_LIBS := -lamdhip64 -lhiprand
    BACKEND_INC := -I/opt/rocm/include
    BACKEND_DEFINE := -D__HIP_PLATFORM_AMD__
else
    export HIP_PLATFORM := nvidia
    GPU_ARCH := -gencode arch=compute_86,code=sm_86 # e.g. sm_86 = RTX 30xx
    GPU_OPT := -O3 # nvcc has no -Ofast
    CUDA_LIBS := -lcudart -lcuda
    BACKEND_INC := -I/usr/local/cuda/include -I/opt/rocm/include
    BACKEND_DEFINE := -D__HIP_PLATFORM_NVIDIA__
endif

ifeq ($(DEBUG),1)
    CXXFLAGS := -std=c++20 -g -O0 $(BACKEND_INC) -fno-omit-frame-pointer -I./includes -I./includes/imgui -I./src/ -MMD -MP $(BACKEND_DEFINE)
    GPU_CFLAGS := -std=c++20 -g -O0 $(BACKEND_INC) -I./includes -I./src/ $(GPU_ARCH) $(BACKEND_DEFINE)
else
    CXXFLAGS := -std=c++20 -Ofast $(BACKEND_INC) -I./includes -I./includes/imgui -I./src/ -MMD -MP $(BACKEND_DEFINE)
    GPU_CFLAGS := -std=c++20 $(GPU_OPT) $(BACKEND_INC) -I./includes -I./src/ $(GPU_ARCH) $(BACKEND_DEFINE)
endif

LDFLAGS := -lglfw -lGL -ldl -lX11 -lpthread -lXrandr -lXi $(CUDA_LIBS)

BUILD_DIR := ./build/$(BACKEND)
TARGET := $(BUILD_DIR)/raytracer

SRC := ./src/main.cpp \
    ./includes/glad/glad.c \
    ./src/misc/stb_image.cpp \
    ./src/misc/shader_util.cpp \
    ./src/GLFW/Window.cpp \
    ./src/GLFW/Input.cpp \
	./src/Engine/Engine.cpp \
	./src/Engine/OBJParser.cpp \
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

OBJ := $(SRC:.cpp=.o)
OBJ := $(OBJ:.c=.o)
OBJ := $(patsubst %,$(BUILD_DIR)/%,$(OBJ))

CUDA_OBJ := $(CUDA_SRC:.cu=.o)
CUDA_OBJ := $(patsubst %,$(BUILD_DIR)/%,$(CUDA_OBJ))

all: $(TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(TARGET): $(BUILD_DIR) $(OBJ) $(CUDA_OBJ)
	$(GPU_CC) $(OBJ) $(CUDA_OBJ) -o $(TARGET) $(LDFLAGS)

$(BUILD_DIR)/%.o: %.cpp | $(BUILD_DIR)
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.cu | $(BUILD_DIR)
	mkdir -p $(dir $@)
	$(GPU_CC) $(GPU_CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)

run: all
	./$(TARGET)

DEPS := $(OBJ:.o=.d)
-include $(DEPS)

.PHONY: all clean run