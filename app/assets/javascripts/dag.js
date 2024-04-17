function buildGraph(dag, nodeValueToLabel) {
  const graph = {};
  const inDegree = {};

  // initialize graph and in-degree
  for (const nodeLabel in nodeValueToLabel) {
    graph[nodeLabel] = [];
    inDegree[nodeLabel] = 0;
  }

  // parse the DAG and build the graph
  const lines = dag.split('\n');
  for (const line of lines) {
    const parts = line.split(':').map(part => part.trim());
    if (parts.length === 2) {
      const nodeLabel = parts[0];
      const dependencies = parts[1].split(' ').filter(label => label !== '');
      for (const dependency of dependencies) {
        if (dependency !== '-1' && nodeValueToLabel[nodeLabel] !== undefined && nodeValueToLabel[dependency] !== undefined) {
          graph[nodeLabel].push(dependency);  // add dependency to the graph
          inDegree[dependency]++;  // increment in-degree of the dependency
        }
      }
    }
  }

  console.log("Graph:", graph);
  console.log("In-degree:", inDegree);
  return { graph, inDegree };
}


function processSolution(solution, graph, inDegree, nodeValueToLabel) {
  console.log("processSolution:", solution);
  console.log("processnodeValueToLabel:", nodeValueToLabel);
  const visited = new Set();

  for (const nodeText of solution) {
    const nodeLabel = Object.keys(nodeValueToLabel).find(
      (label) => nodeValueToLabel[label] === nodeText
    );

    if (nodeLabel === undefined) {
      console.log("Skipping node not found in nodeValueToLabel:", nodeText);
      continue;  // jump to the next node
    }

    console.log('Current label:', nodeLabel);
    console.log('Current node text:', nodeText);
    console.log('Node value to label mapping:', nodeValueToLabel);

    visited.add(nodeLabel);

    // check if the node has dependencies
    for (const dependencyLabel of graph[nodeLabel]) {
      if (!visited.has(dependencyLabel)) {
        console.error("Dependency not satisfied:", nodeText, "depends on", nodeValueToLabel[dependencyLabel]);
        return false;
      }
    }
  }

  // check if all nodes were visited
  if (visited.size !== Object.keys(nodeValueToLabel).length) {
    console.error("Not all nodes in nodeValueToLabel were visited.");
    return false;
  }

  console.log('Visited nodes:', Array.from(visited));
  return true;
}



  
function processDAG(dag, solution, nodeValueToLabel) {
  console.log("DAG:", dag);
  console.log("Node value to label mapping:", nodeValueToLabel);
  const { graph, inDegree } = buildGraph(dag, nodeValueToLabel);
  const result = processSolution(solution, graph, inDegree, nodeValueToLabel);
  return result;
}

function extractCode(solution, nodeValueToLabel) {
    const code = [];
    const newNodeValueToLabel = {};
    for (const nodeText of solution) {
      const nodeLabel = Object.keys(nodeValueToLabel).find(
        (key) => nodeValueToLabel[key] === nodeText
      );
      if (nodeLabel !== undefined) {
        code.push(nodeText);
        newNodeValueToLabel[nodeLabel] = nodeText;
      }
    }
    return { code, newNodeValueToLabel };
  }