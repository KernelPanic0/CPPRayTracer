CXX := g++
DEBUG ?= 1

ifeq ($(DEBUG),1)
CXXFLAGS := -std=c++20 -g -O0 -fno-omit-frame-pointer -I./includes -I./includes/imgui -I./src/ -MMD -MP
else
CXXFLAGS := -std=c++20 -O2 -I./includes -I./includes/imgui -I./src/ -MMD -MP
endif
LDFLAGS := -lglfw -lGL -ldl -lX11 -lpthread -lXrandr -lXi
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
	./src/Engine/Raytracing/Vector.cpp \
	./src/Engine/Raytracing/Sphere.cpp \
	./src/Engine/Raytracing/Camera.cpp \
	./src/Engine/Raytracing/Constants.cpp \
	./src/Engine/Raytracing/Hittable.cpp \
	./src/Engine/Raytracing/Interval.cpp \
	./src/Engine/Raytracing/Material.cpp \
	./src/Engine/Raytracing/Ray.cpp \
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

all: $(TARGET)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(TARGET): $(BUILD_DIR) $(OBJ)
	$(CXX) $(OBJ) -o $(TARGET) $(LDFLAGS)

$(BUILD_DIR)/%.o: %.cpp | $(BUILD_DIR)
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD_DIR)

run: all
	./$(TARGET)

DEPS := $(OBJ:.o=.d)
-include $(DEPS)

.PHONY: all clean run