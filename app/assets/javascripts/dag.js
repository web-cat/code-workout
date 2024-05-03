// Main function to build a graph based on a Directed Acyclic Graph (DAG) representation and a mapping from node values to labels.
function buildGraph(dag, nodeValueToLabel) {
  const graph = {};   // Object to hold the adjacency list representation of the graph.
  const inDegree = {}; // Object to hold the in-degree count for each node.

  // Initialize graph and in-degree for each node based on the nodeValueToLabel mapping.
  for (const nodeLabel in nodeValueToLabel) {
    graph[nodeLabel] = [];
    inDegree[nodeLabel] = 0;
  }

  // Parse the DAG string, build the graph and calculate in-degrees.
  const lines = dag.split('\n');
  for (const line of lines) {
    const parts = line.split(':').map(part => part.trim());
    if (parts.length === 2) {
      const nodeLabel = parts[0];
      const dependencies = parts[1].split(' ').filter(label => label !== '');
      for (const dependency of dependencies) {
        if (dependency !== '-1' && nodeValueToLabel[nodeLabel] !== undefined && nodeValueToLabel[dependency] !== undefined) {
          graph[nodeLabel].push(dependency);  // Add dependency to the node's adjacency list.
          inDegree[dependency]++;  // Increment in-degree count for the dependency.
        }
      }
    }
  }

  console.log("Graph:", graph);
  console.log("In-degree:", inDegree);
  return { graph, inDegree };
}

// Processes the solution by validating the sequence of nodes against the graph's dependencies.
function processSolution(solution, graph, inDegree, nodeValueToLabel) {
  console.log("processSolution:", solution);
  console.log("processnodeValueToLabel:", nodeValueToLabel);
  const visited = new Set(); // Set to track visited nodes.

  // Process each node in the solution, ensuring all dependencies are met.
  for (const nodeText of solution) {
    const nodeLabel = Object.keys(nodeValueToLabel).find(
      label => nodeValueToLabel[label] === nodeText
    );

    if (nodeLabel === undefined) {
      console.log("Skipping node not found in nodeValueToLabel:", nodeText);
      continue; // Skip if node is not found in mapping.
    }

    console.log('Current label:', nodeLabel);
    console.log('Current node text:', nodeText);
    console.log('Node value to label mapping:', nodeValueToLabel);

    visited.add(nodeLabel);

    // Check if all dependencies of the current node have been visited.
    for (const dependencyLabel of graph[nodeLabel]) {
      if (!visited.has(dependencyLabel)) {
        console.error("Dependency not satisfied:", nodeText, "depends on", nodeValueToLabel[dependencyLabel]);
        return false; // Dependency check failed.
      }
    }
  }

  // Ensure all nodes were visited.
  if (visited.size !== Object.keys(nodeValueToLabel).length) {
    console.error("Not all nodes in nodeValueToLabel were visited.");
    return false;
  }

  console.log('Visited nodes:', Array.from(visited));
  return true; // All checks passed.
}

// High-level function to process the DAG and the solution together.
function processDAG(dag, solution, nodeValueToLabel) {
  console.log("DAG:", dag);
  console.log("Node value to label mapping:", nodeValueToLabel);
  const { graph, inDegree } = buildGraph(dag, nodeValueToLabel);
  const result = processSolution(solution, graph, inDegree, nodeValueToLabel);
  return result;
}

// Extracts and maps the solution to the corresponding node labels.
function extractCode(solution, nodeValueToLabel) {
    const code = [];
    const newNodeValueToLabel = {};
    for (const nodeText of solution) {
      const nodeLabel = Object.keys(nodeValueToLabel).find(
        key => nodeValueToLabel[key] === nodeText
      );
      if (nodeLabel !== undefined) {
        code.push(nodeText);  // Collect the node text for the final code array.
        newNodeValueToLabel[nodeLabel] = nodeText; // Map labels to node texts.
      }
    }
    return { code, newNodeValueToLabel }; // Return the processed code and updated mapping.
  }
