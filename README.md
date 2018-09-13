# Test

##Technical Description
It's an realization of simple HTTP API Web Server using Elixir Language. Importing of realization HTTP Server is from Stargate library - realization with the best performance for HTTP API Web Server purposes.
The API data is given in csv format , but i've decided to start uploading of the data to the ets table just after start of the Application. Using of ETS table in role of an storage for existing data that is needed to be in API Data it's the best choice for better performance of API. This Project it's an Application named Test , which contains HttpServer as child process and can be extended by adding some new child processes of Application like DB or smth like this.

## Deployment
For deployment of this Http Api Server you should follow next steps:
```
git clone https://github.com/JohnPochta/elixir_http_api_docker
docker build -t image_name .
docker run -p port:4000 -t image_name
#example run -p 8080:4000 -t image_name
```
##User Guide
Api Data there is results of football matches in different championships.
This Api has 2 supported response types: JSON and Protocol Buffers. Which of them you want to get - you can choose by starting your URL from 
/json_api for JSON response
and
/protobuf_api for Protocol Buffers response, where Protocol Buffer encoded in hex-string and response body should previosly be decoded from hex and after that be decoded by Protocol Buffers. 
Next part of URL it's the name of method which you want to call. It can be:
```
GET: /list - method that gives a list of tournament and season pairs for which in data.csv file available football matches results

Examples:
	/json_api :
		Request :
			curl 'http://localhost:port/json_api/list'
		Response Body:
			{"list": [{"season":201617,"tournament":"SP2"}, ...]}
	/protobuf_api :
		Request :
			curl 'http://localhost:port/protobuf_api/list'
		Response Body:
			0a090a035350321091a70c0a080a0245301091a70c0a080a0244311091a70c0a090a035350311091a70c0a090a0353503210aca60c0a090a0353503110aca60
		Test :
			hex = 0a090a035350321091a70c0a080a0245301091a70c0a080a0244311091a70c0a090a035350311091a70c0a090a0353503210aca60c0a090a0353503110aca60
			hexdec = Base.decode16!(hex, case: :mixed)
			Protobufs.ListMsg.decode(hexdec)
			And here we go, it's valid Protocol Buffer
```

```
GET: /fetch_results?season=&tournament= - method that gives a list of tournament and season pairs for which in data.csv file available football matches results
Examples:
	/json_api :
		Request :
			curl 'http://localhost:port/json_api/fetch_results?season=201617&tournament=E0'
		Response Body:
			{"result":[{"away_team":"Swansea","date":"13/8/2016","ftag":"1","fthg":"0","ftr":"A","home_team":"Burnley","htag":"0","hthg":"0","htr":"D","id":1685,"season":201617,"tournament":"E0"}, ...]}
	/protobuf_api :
		Request :
			curl 'http://localhost:port/protobuf_api/fetch_results?season=201617&tournament=E0'
		Response Body:
			0a3608950d12074275726e6c65791a075377.....
```