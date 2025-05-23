# Node program Editor

Node program editor is a Flutter package based on the flutter package diagram_editor.


## Description

The package provide a NodeProgramEditor widget witch is an editor dashboard who look like this :

![alt text](image.png)


## How to use 

You can use the node program editor widget in any other Flutter.
The widget need a mandatory argument a json type data who need to had this specific format : 
```json
{
      "input_types": [],
      "blocks": [
        {
          "name": "block_name",
          "input": [{
              "name": "input_name",
              "type": "type_from_type_array",
              "mandatory": true,
            }],
          "output": [
            {
              "name": "output_name",
              "type": "type_from_type_array",
              "mandatory": true,
            }
          ],
          "parameter": [
            {
              "name": "param_name",
              "type": "DROPDOWN",
              "value": []
            }
          ]
        },
      ]
    }
```

The parameters type depend on the field type that you want to have when update the block. The package allow this types of parameters type :
- INT_FIELD => only integer values
- STRING_FIELD => basic Flutter text input
- FILE_FIELD => file picker
- FOLDER_FIELD => directory picker
- DROPDOWN => dropdown
- FLOAT_FIELD => ensure that the value is a digit
- COLOR_FIELD => color picker

you can also use an optional parameters onProgramEmitted witch is a callback function that return the program logic execution => the block parameters, the link between blocks,...

the other parameters are :
- height,
- width,
- programName,
- appName