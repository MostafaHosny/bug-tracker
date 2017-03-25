# README
after you clone the project cd to dir 
and run docker-compose-up 
there is 4 images will run 
bugtracker_web_1 
bugtracker_rabbit1_1 
bugtracker_db_1 
bugtracker_elasticsearch_1

you need to run the migration of database it's created but you just need to run this command 
 "docker-compose run web rake db:migrate" 

now you can test  
1-insert bug theroug this api 
type: POST 
url:localhost:3000/api/v1/bugs
headres => token: 5 , Content-Type = application/json 
body = 
{
 "bug": { "status":"new" , "comment": "hehee" , "priority": "minor"} ,
 "state":{"device":"iPhone" , "os":"android" , "memory": "1024" , "storage" : "20480" }
}


2-show bug by id 

type: get 
url:localhost:3000/api/v1/bugs/[id]
headres => token: 5 , Content-Type = application/json

response 

{
  "id": 1,
  "number": 1,
  "status": "new",
  "priority": "minor",
  "comment": "hehee",
  "state": {
    "id": 1,
    "device": "iPhone",
    "os": "android",
    "memory": 1024,
    "storage": 20480
  }
}


to test search method run this command and go to the console 
"docker-compose run web rails c" 

Bug.elk_search (any word you want to search )





