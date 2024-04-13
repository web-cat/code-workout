// 根据 DAG 描述构建图
function buildGraph(dag, nodeValueToLabel) {
    const graph = {};
    const lines = dag.trim().split('\n');
  
    for (const line of lines) {
      const [node, ...parents] = line.split(':').map(item => item.trim());
      const label = nodeValueToLabel[node];
      if (parents.length === 0 || parents[0] === '') {
        graph[label] = [];
      } else {
        const validParents = parents.map(parent => nodeValueToLabel[parent]).filter(parent => parent !== '');
        graph[label] = validParents;
      }
    }
  
    return graph;
  }
  
  // 构建入度数组并初始化队列
  function initializeCounts(graph) {
    const inDegree = {};
    const queue = [];
  
    for (const node in graph) {
      inDegree[node] = graph[node].length;
      if (inDegree[node] === 0) {
        queue.push(node);
      }
    }
  
    return { inDegree, queue };
  }
  

  function processSolution(graph, inDegree, queue, solution, nodeValueToLabel) {
    const visited = new Set();
    if (Array.isArray(solution)) {
      solution = solution.join('\n');
    } else if (typeof solution !== 'string') {
      throw new TypeError('The solution must be a string or an array.');
    }
  
    const solutionNodes = solution.split('\n').map(line => line.trim());
    const graphNodes = Object.keys(graph).filter(node => node !== '__root__');  // 排除虚拟根节点
  
    console.log("Solution nodes:", solutionNodes);
    console.log("Graph nodes:", graphNodes);
  
    // 检查学生的解答中的项目数量是否与图中的节点数量匹配
    if (solutionNodes.length !== graphNodes.length) {
      throw new Error('Number of items in student solution does not match the number of nodes in the graph.');
    }
  
    for (const node of solutionNodes) {  // 修改这里
      console.log("Current node:", node);
      console.log("Current queue:", queue);
  
      // 查找节点对应的标签
      const label = node;  // 修改这里
      if (!label) {
        console.log("Node label not found, returning false");
        return false;
      }
  
      // 如果当前节点的标签不在队列中,返回false
      if (!queue.includes(label)) {
        console.log("Node label not in queue, returning false");
        return false;
      }
  
      // 将当前节点的标签从队列中移除
      queue.splice(queue.indexOf(label), 1);
      visited.add(label);
  
      // 更新相邻节点的入度,并将入度变为0的节点加入队列
      for (const neighbor in graph) {
        if (graph[neighbor].includes(label)) {
          inDegree[neighbor]--;
          if (inDegree[neighbor] === 0) {
            queue.push(neighbor);
          }
        }
      }
      console.log("Updated in-degree:", inDegree);
      console.log("Updated queue:", queue);
    }
  
    // 如果所有节点都被访问过,返回true,否则返回false
    const allVisited = visited.size === Object.keys(graph).length;
    console.log("All nodes visited:", allVisited);
    return allVisited;
  }
  
  function processDAG(dag, solution) {
    const nodeValueToLabel = {
        "one": "print('Hello')",
        "two": "print('Parsons')",
        "three": "print('Problems!')"
      };
  
    const graph = buildGraph(dag, nodeValueToLabel);
    const { inDegree, queue } = initializeCounts(graph);
    const result = processSolution(graph, inDegree, queue, solution, nodeValueToLabel);
    return result;
  }