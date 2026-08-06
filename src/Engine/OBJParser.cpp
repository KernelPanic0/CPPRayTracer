#include "OBJParser.hpp"
OBJParser::OBJParser() {
}

std::vector<RawTriangleData> OBJParser::ReadFile(const char *path) {
    std::string line;
    std::vector<RawTriangleData> triangles;
    std::vector<Vector3> vertices;

    vertices.resize(3);

    std::ifstream reader(path);

    int lineNumber = 0;
    while (getline(reader, line)) {
        if (!line.starts_with("v "))
            continue;

        size_t coordinateIndex = 0;
        std::istringstream iss(line);

        // bad
        std::string dummy;
        iss >> dummy;
        double x, y, z;
        iss >> x >> y >> z;

        vertices[lineNumber % 3] = Vector3(x, y, z - 15);

        if (lineNumber % 3 == 2) {
            triangles.push_back({{vertices[0], vertices[1], vertices[2]}, {MaterialType::DiffuseLight, Triplet(0.08, 0.4, 0.1), 0.0, 2.0}}); // this needs to be done better too
        }
        lineNumber++;
    }

    reader.close();
    return triangles;
}