#include "OBJParser.hpp"
OBJParser::OBJParser() {
}

std::vector<RawTriangleData> OBJParser::ReadFile(const char *path) {
    std::string line;
    std::vector<RawTriangleData> triangles;
    std::vector<Vector3> vertices;

    std::ifstream reader(path);

    int lineNumber = 0;
    while (getline(reader, line)) {
        if (!(line.starts_with("v ") || line.starts_with("f ")))
            continue;

        size_t coordinateIndex = 0;
        std::istringstream iss(line);

        if (line.starts_with("v ")) {
            std::string dummy;
            iss >> dummy;
            double x, y, z;
            iss >> x >> y >> z;

            vertices.emplace_back(x, y - 2, z - 5);
        } else {
            std::string dummy;
            iss >> dummy;
            std::string x, y, z;
            iss >> x >> y >> z;

            std::vector<std::string> indices;
            boost::split(indices, x, boost::is_any_of("/"));
            Vector3 vx = vertices[std::stoi(indices[0]) - 1];

            indices.resize(0);
            boost::split(indices, y, boost::is_any_of("/"));
            Vector3 vy = vertices[std::stoi(indices[0]) - 1];

            indices.resize(0);
            boost::split(indices, z, boost::is_any_of("/"));
            Vector3 vz = vertices[std::stoi(indices[0]) - 1];

            triangles.push_back({{vx, vy, vz}, {MaterialType::Metal, Triplet(0.60, 0.06, 0.11), 0.5}}); // this needs to be done better too
        }

        if (lineNumber % 3 == 2) {
        }
        lineNumber++;
    }

    reader.close();
    return triangles;
}