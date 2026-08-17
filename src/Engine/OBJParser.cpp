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

            // rotate 90 degrees around X
            Vector3 ColOne(1, 0, 0);
            Vector3 ColTwo(0, 0, 1);
            Vector3 ColThree(0, -1, 0);

            double vx_X = vx.x * ColOne.x + vx.y * ColTwo.x + vx.z * ColThree.x;
            double vx_Y = vx.x * ColOne.y + vx.y * ColTwo.y + vx.z * ColThree.y;
            double vx_Z = vx.x * ColOne.z + vx.y * ColTwo.z + vx.z * ColThree.z;

            double vy_X = vy.x * ColOne.x + vy.y * ColTwo.x + vy.z * ColThree.x;
            double vy_Y = vy.x * ColOne.y + vy.y * ColTwo.y + vy.z * ColThree.y;
            double vy_Z = vy.x * ColOne.z + vy.y * ColTwo.z + vy.z * ColThree.z;

            double vz_X = vz.x * ColOne.x + vz.y * ColTwo.x + vz.z * ColThree.x;
            double vz_Y = vz.x * ColOne.y + vz.y * ColTwo.y + vz.z * ColThree.y;
            double vz_Z = vz.x * ColOne.z + vz.y * ColTwo.z + vz.z * ColThree.z;

            // vx.x = vx_X;
            // vx.y = vx_Y - 2;
            // vx.z = vx_Z - 5;

            // vy.x = vy_X;
            // vy.y = vy_Y - 2;
            // vy.z = vy_Z - 5;

            // vz.x = vz_X;
            // vz.y = vz_Y - 2;
            // vz.z = vz_Z - 5;
            triangles.push_back({{vx, vy, vz}, {MaterialType::Metal, Triplet(0.60, 0.06, 0.11), 0.5}}); // this needs to be done better too
        }

        if (lineNumber % 3 == 2) {
        }
        lineNumber++;
    }

    reader.close();
    return triangles;
}