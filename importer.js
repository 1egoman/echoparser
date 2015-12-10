'use strict';
const _ = require("underscore");

let swagger = {
  "swagger": "2.0",
  "info": {
    "version": "1.0.0",
    "title": "Swagger Petstore",
    "description": "A sample API that uses a petstore as an example to demonstrate features in the swagger-2.0 specification",
    "termsOfService": "http://swagger.io/terms/",
    "contact": {
      "name": "Swagger API Team"
    },
    "license": {
      "name": "MIT"
    }
  },
  "host": "petstore.swagger.io",
  "basePath": "/api",
  "schemes": [
    "http"
  ],
  "consumes": [
    "application/json"
  ],
  "produces": [
    "application/json"
  ],
  "paths": {
    "/pets": {
      "get": {
        "description": "Returns all pets from the system that the user has access to",
        "operationId": "findPets",
        "produces": [
          "application/json",
          "application/xml",
          "text/xml",
          "text/html"
        ],
        "parameters": [
          {
            "name": "tags",
            "in": "query",
            "description": "tags to filter by",
            "required": false,
            "type": "array",
            "items": {
              "type": "string"
            },
            "collectionFormat": "csv"
          },
          {
            "name": "limit",
            "in": "query",
            "description": "maximum number of results to return",
            "required": false,
            "type": "integer",
            "format": "int32"
          }
        ],
        "responses": {
          "200": {
            "description": "pet response",
            "schema": {
              "type": "array",
              "items": {
                "$ref": "#/definitions/Pet"
              }
            }
          },
          "default": {
            "description": "unexpected error",
            "schema": {
              "$ref": "#/definitions/ErrorModel"
            }
          }
        }
      },
      "post": {
        "description": "Creates a new pet in the store.  Duplicates are allowed",
        "operationId": "addPet",
        "produces": [
          "application/json"
        ],
        "parameters": [
          {
            "name": "pet",
            "in": "body",
            "description": "Pet to add to the store",
            "required": true,
            "schema": {
              "$ref": "#/definitions/PetInput"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "pet response",
            "schema": {
              "$ref": "#/definitions/Pet"
            }
          },
          "default": {
            "description": "unexpected error",
            "schema": {
              "$ref": "#/definitions/ErrorModel"
            }
          }
        }
      }
    },
    "/pets/{id}": {
      "get": {
        "description": "Returns a user based on a single ID, if the user does not have access to the pet",
        "operationId": "findPetById",
        "produces": [
          "application/json",
          "application/xml",
          "text/xml",
          "text/html"
        ],
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "description": "ID of pet to fetch",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "200": {
            "description": "pet response",
            "schema": {
              "$ref": "#/definitions/Pet"
            }
          },
          "default": {
            "description": "unexpected error",
            "schema": {
              "$ref": "#/definitions/ErrorModel"
            }
          }
        }
      },
      "delete": {
        "description": "deletes a single pet based on the ID supplied",
        "operationId": "deletePet",
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "description": "ID of pet to delete",
            "required": true,
            "type": "integer",
            "format": "int64"
          }
        ],
        "responses": {
          "204": {
            "description": "pet deleted"
          },
          "default": {
            "description": "unexpected error",
            "schema": {
              "$ref": "#/definitions/ErrorModel"
            }
          }
        }
      }
    }
  },
  "definitions": {
    "Pet": {
      "type": "object",
      "required": [
        "id",
        "name"
      ],
      "properties": {
        "id": {
          "type": "integer",
          "format": "int64"
        },
        "name": {
          "type": "string"
        },
        "tag": {
          "type": "string"
        }
      }
    },
    "PetInput": {
      "type": "object",
      "allOf": [
        {
          "$ref": "#/definitions/Pet"
        },
        {
          "required": [
            "name"
          ],
          "properties": {
            "id": {
              "type": "integer",
              "format": "int64"
            }
          }
        }
      ]
    },
    "ErrorModel": {
      "type": "object",
      "required": [
        "code",
        "message"
      ],
      "properties": {
        "code": {
          "type": "integer",
          "format": "int32"
        },
        "message": {
          "type": "string"
        }
      }
    }
  }
}

// ----------------------------------------------------------------------------
// Defined utterances
// ----------------------------------------------------------------------------

// we can match against this to find utterances to start with
const utterances = {
  "getAll": [
    "all {n}s",
    "get all {n}s",
    "retreive all {n}s",
  ],
  "get": [
    "find "
  ]
}


// ----------------------------------------------------------------------------
// Utility functions
// ----------------------------------------------------------------------------

// is the specified word plural?
exports.isPlural = (word) => {
  return word.split('').reverse()[0] === 's';
};

// does a phrase contain a word from a list
let containsFromList = (phrase, list) => {
  return _.intersection(phrase.split(' '), list).length > 0;
}

// get the base part from any route, and capitalize it
// ie, `/pets` -> pets
//     `/pets/{id}` -> pets
let getBaseForRoute = (route) => {
  let base = route.split('/').filter((i) => i.length)[0];
  return `${base[0].toUpperCase()}${base.slice(1)}`;
}


// which actions should be converted for a specified path
exports.actionForName = (name, method, data) => {
  const GROUP_WORDS = ["all", "collection", "group", "list"];

  // Does this route return a list of mutiple items? If so, postfix with `All`.
  if (containsFromList(data.description, GROUP_WORDS)) {
    method += "All";
  };

  return {
    name: method + getBaseForRoute(name),
    method: method,
    data: data
  }
};



// generate skills for the passd-in swagger file
exports.generateSkills = (swagger) => {
  
  for (let route in swagger.paths) {
    for (let method in swagger.paths[route]) {

      // access the data for the specified route and method
      let data = swagger.paths[route][method];
      let parsed = exports.actionForName(route, method, data);

      // the starting definition
      console.log(`swagger.${parsed.name}`);

      // add the utterances
      console.log(`  get all pets`)
      console.log(`  ---\n`)

    }
  }

};


exports.generateSkills(swagger)
