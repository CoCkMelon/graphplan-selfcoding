#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <expat.h>

#define MAXCHARS 1000000

// A structure to represent a graph node
typedef struct graph_node {
  char *id; // The node id
  char *label; // The node label
  struct graph_node *next; // The next node in the list
} graph_node_t;

// A structure to represent a graph edge
typedef struct graph_edge {
  char *source; // The source node id
  char *target; // The target node id
  char *label; // The edge label
  struct graph_edge *next; // The next edge in the list
} graph_edge_t;

// A structure to represent a graph
typedef struct graph {
  graph_node_t *nodes; // The list of nodes
  graph_edge_t *edges; // The list of edges
} graph_t;

// A global variable to store the current graph
graph_t *graph = NULL;

// A function to create a new graph node
graph_node_t *create_graph_node(char *id, char *label) {
  graph_node_t *node = (graph_node_t *)malloc(sizeof(graph_node_t));
  node->id = strdup(id);
  // Check if label is NULL
  if (label == NULL) {
    // Assign a default value or an empty string
    node->label = strdup("");
  } else {
    // Copy the label as usual
    node->label = strdup(label);
  }
  node->next = NULL;
  return node;
}

// A function to create a new graph edge
graph_edge_t *create_graph_edge(char *source, char *target, char *label) {
  graph_edge_t *edge = (graph_edge_t *)malloc(sizeof(graph_edge_t));
  edge->source = strdup(source);
  edge->target = strdup(target);
  // Check if label is NULL
  if (label == NULL) {
    // Assign a default value or an empty string
    edge->label = strdup("");
  } else {
    // Copy the label as usual
    edge->label = strdup(label);
  }
  edge->next = NULL;
  return edge;
}

// A function to add a node to the graph
void add_graph_node(graph_t *graph, graph_node_t *node) {
  if (graph == NULL || node == NULL) return;
  if (graph->nodes == NULL) {
    // The first node in the list
    graph->nodes = node;
  } else {
    // Append the node to the end of the list
    graph_node_t *current = graph->nodes;
    while (current->next != NULL) {
      current = current->next;
    }
    current->next = node;
  }
}

// A function to add an edge to the graph
void add_graph_edge(graph_t *graph, graph_edge_t *edge) {
  if (graph == NULL || edge == NULL) return;
  if (graph->edges == NULL) {
    // The first edge in the list
    graph->edges = edge;
  } else {
    // Append the edge to the end of the list
    graph_edge_t *current = graph->edges;
    while (current->next != NULL) {
      current = current->next;
    }
    current->next = edge;
  }
}

// A function to print a graph node
void print_graph_node(graph_node_t *node) {
  if (node == NULL) return;
  printf("Node: id=%s, label=%s\n", node->id, node->label);
}

// A function to print a graph edge
void print_graph_edge(graph_edge_t *edge) {
  if (edge == NULL) return;
  printf("Edge: source=%s, target=%s, label=%s\n", edge->source, edge->target, edge->label);
}

// A function to print a graph
void print_graph(graph_t *graph) {
  if (graph == NULL) return;
  printf("Graph:\n");
  printf("Nodes:\n");
  // Print all nodes in the list
  graph_node_t *node = graph->nodes;
  while (node != NULL) {
    print_graph_node(node);
    node = node->next;
  }
  printf("Edges:\n");
  // Print all edges in the list
  graph_edge_t *edge = graph->edges;
  while (edge != NULL) {
    print_graph_edge(edge);
    edge = edge->next;
  }
}

// A function to free a graph node
void free_graph_node(graph_node_t *node) {
  if (node == NULL) return;
  free(node->id);
  free(node->label);
  free(node);
}

// A function to free a graph edge
void free_graph_edge(graph_edge_t *edge) {
  if (edge == NULL) return;
  free(edge->source);
  free(edge->target);
  free(edge->label);
  free(edge);
}

// A function to free a graph
void free_graph(graph_t *graph) {
  if (graph == NULL) return;
  // Free all nodes in the list
  graph_node_t *node = graph->nodes;
  while (node != NULL) {
    graph_node_t *next = node->next;
    free_graph_node(node);
    node = next;
  }
  // Free all edges in the list
  graph_edge_t *edge = graph->edges;
  while (edge != NULL) {
    graph_edge_t *next = edge->next;
    free_graph_edge(edge);
    edge = next;
  }
  // Free the graph itself
  free(graph);
}

graph_node_t *last_node;
graph_edge_t *last_edge;
  // A global variable to store the current element name
char *current_element = NULL;
char keynow = 0;
char edgenow = 0;
char nodenow = 0;

// A function to handle the start of an XML element
void start(void *data, const char *element, const char **attr) {
  if (strcmp(element, "graphml") == 0) {
    // The root element of GraphML
    // Create a new graph object
    graph = (graph_t *)malloc(sizeof(graph_t));
    graph->nodes = NULL;
    graph->edges = NULL;
  } else if (strcmp(element, "node") == 0) {
    // A node element in GraphML
    // Get the node id and label attributes
    char *id = NULL;
    char *label = NULL;
    for (int i = 0; attr[i]; i += 2) {
      if (strcmp(attr[i], "id") == 0) {
        id = (char *)attr[i + 1];
      } else if (strcmp(attr[i], "label") == 0) {
        label = (char *)attr[i + 1];
      }
    }
    // Create a new graph node object
    graph_node_t *node = create_graph_node(id, label);
    // Add the node to the graph
    add_graph_node(graph, node);
    last_node = node;
    nodenow = 1;
    edgenow = 0;
  } else if (strcmp(element, "edge") == 0) {
    // An edge element in GraphML
    // Get the edge source, target and label attributes
    char *source = NULL;
    char *target = NULL;
    char *label = NULL;
    for (int i = 0; attr[i]; i += 2) {
      if (strcmp(attr[i], "source") == 0) {
        source = (char *)attr[i + 1];
      } else if (strcmp(attr[i], "target") == 0) {
        target = (char *)attr[i + 1];
      } else if (strcmp(attr[i], "label") == 0) {
        label = (char *)attr[i + 1];
      }
    }
    // Create a new graph edge object
    graph_edge_t *edge = create_graph_edge(source, target, label);
    // Add the edge to the graph
    add_graph_edge(graph, edge);
    last_edge = edge;
    edgenow = 1;
    nodenow = 0;
  } else if (strcmp(element, "data") == 0) {
    // A data element in GraphML
    // Get the data key and value attributes
    char *key = NULL;
    char *value = NULL;
    // printf("%s ", attr);
    for (int i = 0; attr[i]; i += 2) {
      if (strcmp(attr[i], "key") == 0) {
        key = (char *)attr[i + 1];
      } else if (strcmp(attr[i], "value") == 0) {
        value = (char *)attr[i + 1];
      }
    }
    // Find the last added node or edge in the graph
    // graph_node_t *node = graph->nodes;
    // graph_edge_t *edge = graph->edges;
    // while (node->next != NULL) {
    //   node = node->next;
    // }
    // while (edge->next != NULL) {
    //   edge = edge->next;
    // }
    // Check the data key and assign the value to the node or edge
    if (strcmp(key, "label") == 0) {
      keynow = 1;
      // printf("%s\n", value);
      last_node->label = value;
    }
    // if (strcmp(key, "shape") == 0) {
    //   node->shape = value;
    // } else if (strcmp(key, "x") == 0) {
    //   node->x = atoi(value);
    // } else if (strcmp(key, "y") == 0) {
    //   node->y = atoi(value);
    // }
  }
}

// A function to handle the character data inside an element
// void charData(void *userData, const XML_Char *s, int len) {
//   // Print the character data to standard output
//   printf("%.*s", len, s);
// }
// A function to handle the character data inside an element

// A function to get the value of an attribute given its name and an array of attribute name-value pairs
char *get_attr_value(const char **attr, const char *name) {
  for (int i = 0; attr[i]; i += 2) {
    if (strcmp(attr[i], name) == 0) {
      return (char *)attr[i + 1];
    }
  }
  return NULL;
}
void charData(void *userData, const XML_Char *s, int len) {
  // Check if the current element is <data> and has key="label"
  if(keynow) {
    // Print the character data to standard output
    // printf("%.*s", len, s);
    if(edgenow) {
      last_edge->label = strndup(s, len);
    } else if(nodenow) {
      last_node->label = strndup(s, len);
    }
    keynow = 0;
  }
}
// A function to handle the end of an XML element
void end(void *data, const char *element) {
  // Nothing to do here
}

// A function to generate a GraphML file from a graph structure
void generate_graphml(graph_t *graph) {
  // Open a file for writing
  FILE *fp = fopen("graph.graphml", "w");
  if (!fp) {
    fprintf(stderr, "Couldn't open file for writing\n");
    return;
  }

  // Write the XML declaration and the root element
  fprintf(fp, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
  fprintf(fp, "<graphml xmlns=\"http://graphml.graphdrawing.org/xmlns\"\n");
  fprintf(fp, "         xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n");
  fprintf(fp, "         xsi:schemaLocation=\"http://graphml.graphdrawing.org/xmlns\n");
  fprintf(fp, "         http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd\">\n");

  // Write the key elements for node and edge labels
  fprintf(fp, "  <key id=\"label\" for=\"node\" attr.name=\"label\" attr.type=\"string\"/>\n");
  fprintf(fp, "  <key id=\"label\" for=\"edge\" attr.name=\"label\" attr.type=\"string\"/>\n");

  // Write the graph element with the default edge direction
  fprintf(fp, "  <graph id=\"G\" edgedefault=\"undirected\">\n");

  // Write the node elements with their labels
  graph_node_t *node = graph->nodes;
  while (node != NULL) {
    fprintf(fp, "    <node id=\"%s\">\n", node->id);
    fprintf(fp, "      <data key=\"label\">%s</data>\n", node->label);
    fprintf(fp, "    </node>\n");
    node = node->next;
  }

  // Write the edge elements with their source, target and label
  graph_edge_t *edge = graph->edges;
  while (edge != NULL) {
    fprintf(fp, "    <edge source=\"%s\" target=\"%s\">\n", edge->source, edge->target);
    fprintf(fp, "      <data key=\"label\">%s</data>\n", edge->label);
    fprintf(fp, "    </edge>\n");
    edge = edge->next;
  }

  // Write the closing tags for the graph and the root element
  fprintf(fp, "  </graph>\n");
  fprintf(fp, "</graphml>\n");

  // Close the file
  fclose(fp);
}
// The main function
int main(int argc, char **argv) {
  if (argc != 2) {
    fprintf(stderr, "Usage: %s filename\n", argv[0]);
    return(1);
  }

  char *filename = argv[1]; // The XML file name

  XML_Parser parser = XML_ParserCreate(NULL); // The XML parser object

  if (parser == NULL) {
    fprintf(stderr, "Parser not created\n");
    return(1);
  }

  // Set the element handler functions
  XML_SetElementHandler(parser, start, end);

  // Set the character data handler function
  XML_SetCharacterDataHandler(parser, charData);

  FILE *f = fopen(filename, "r"); // The XML file pointer

  if (f == NULL) {
    fprintf(stderr, "Cannot open file %s\n", filename);
    return(1);
  }

  char *xmltext = (char *)malloc(MAXCHARS); // The buffer to store the XML file content

  if (xmltext == NULL) {
    fprintf(stderr, "Cannot allocate memory for buffer\n");
    return(1);
  }

  // Read the XML file into the buffer
  size_t size = fread(xmltext, sizeof(char), MAXCHARS, f);

  if (size == 0) {
    fprintf(stderr, "Cannot read file %s\n", filename);
    return(1);
  }

  // Parse the XML file using the buffer
  if (XML_Parse(parser, xmltext, strlen(xmltext), XML_TRUE) == XML_STATUS_ERROR) {
    fprintf(stderr, "Cannot parse file %s: %s\n", filename, XML_ErrorString(XML_GetErrorCode(parser)));
    return(1);
  }

  // Free the parser object
  XML_ParserFree(parser);

  // Close the XML file
  fclose(f);

  // Print the graph object
  print_graph(graph);

  generate_graphml(graph);

  // Free the graph object
  free_graph(graph);

  return(0);
}
