# GJSON
Very simple JSON parser written in Swift 3 based on case sensitive string paths.

# Goal
We all need to use JSON structs in our projects, but unfortunately there is no any stable repository about JSON updated to Swift 3 syntax. So I've decided to make my own, very simple JSON parser that allows you to manage JSON values.

This is not a library, you can just copy & paste my code inside your project. Please feel free to use & modify this code for your projects' requirements.

# Usage
* `GJSON` uses simple string paths (components must be separated with slash `/`) to extract values from valid JSON objects.
* The first option is to extract optional value of `Any?` type. It does not produce any errors or exceptions during parsing, if there is no value that you've requested - you will just receive `nil` as a result and small log message containing information about what was happened.
* Also you can extract optional "strictly typed" values (they just need to be unwrapped, this allow you to extract `null` values safely).
* As a special feature you can extract a concrete item from an internal JSON array by specifying string component prefixed by `:`, for example: `Result/Items/:2` (index starts from zero, instead of `2` you can print any index inside json array's bounds).

# Quick Guide

* Please note that path strings are **case sensitive**.
* Use `number`, `string`, `bool`, `array` or `object` instance-level methods of the `GJSON` class to get strictly typed values as a result. These method will return `nil` if JSON code does not contain specified value types at specified paths. 
* Use strict `valueAt(_, of:)` method which will return strictly typed value or throw an exception if any error occured during parsing.
* Use `any` instance-level method or `GJSON.path(_, json:)` class-level method to extract value of type `Any?`. Just don't forget to unwrap them when it's necessary.
* Use special `myJson/jsonArrayItem/:3` index specifying to extract the concrete item of an array.

# Example
Let's take this JSON code on some server address `https://myserver.com/json`:

```json
{
	"glossary": {
		"title": "example",
		"items": [
			{ "Id": 5, "text": "some item" },
			{ "Id": 28, "text": "some another item" }
		],
		"GlossList": {
			"GlossEntry": {
				"ID": "SGML",
				"SortDesc": true,
				"GlossDef": {
					"GlossSeeAlso": ["GML", "XML"]
				},
				"GlossSee": "markup"
			}
		}
	}
}
```
Here are an example of items extraction:

```swift
// receive our JSON with async URLSession data task
let urlString = "https://myserver.com/json"
let url = URL(string: urlString)
var request = URLRequest(url: url!)
request.httpMethod = "GET"
// send async task
let task = URLSession.shared.dataTask(with: request) { (data, res, err) in
  let object = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)
  App.parseJSON(object)
}
task.resume()

...

class App {
  static func parseJSON(_ json: Any?) {
    let parser = GJSON(json)
    let glossary = GJSON(parser.any("glossary")!)!
    print(glossary.number("items/:0/Id")!) // extract the "Id" property of the first item of an array
    print(glossary.string("GlossList/GlossEntry/ID")!)
    print(glossary.bool("GlossList/GlossEntry/SortDesc")!)
    print(GJSON.path("glossary/GlossList/GlossEntry/GlossSee", json: json) as! String)
  }
}
```

This will print the following lines:

```
5
SGML
true
markup
```
# License
MIT
