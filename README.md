# Chat Application

This is a chat application built with Ruby on Rails.

## Table of Contents

- [Features](#features)
- [Setup](#setup)
- [API-Documentation](#api-documentation)
- [Technologies](#technologies)
- [Challenges and Future Enhancements](#challenges-and-future-enhancements)

## Features

- **Application Creation**: Users can create new applications with a generated token and a provided name.
- **Chat Management**: Each application can have multiple chats, each uniquely numbered.
- **Message Management**: Chats can contain messages, each uniquely numbered.
- **Search Functionality**: An endpoint is provided to search through messages within a specific chat, allowing partial matches on message bodies.
- **Data Counts**: The applications table contains a `chats_count` column, and the chats table contains a `messages_count` column to keep track of the number of chats and messages, respectively.

## Setup

### Prerequisites

Make sure you have the following installed:

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

### Running the Application

1. Clone the repository:

   ```
   git clone <repository-url>
   ```

2. Build and start the Docker Containers
    ``` 
    docker-compose up --build
    ```
3. For the Search API to work properly we need to index the messages: (_This was Challenging to include in Docker_)

   ```
   # From the terminal, execute a bash shell inside the chat_app container
   docker exec -it chat_app /bin/bash

   # install rails
   gem install rails

   # index the Messsages using SearchKick
   rails searchkick:reindex CLASS=Message
   ```
4. Application should now be running on `http://localhost:3000`, you can use a tool like Postman to make requests


## API Documentation

### Endpoints

#### Create an application: `POST /applications`
Application name should be unique

##### Sample Body
```
{
    "name": "WhatsApp"
}
```

##### Successful Response

```
{
    "token": "c16eeab416359d7f34a190b1836053cf"
}
```


#### Update an application name: `PATCH /applications/:application_number`


##### Sample Body

```
{
    "name": "Facebook"
}
```

##### Successful Response

```
{
    "token": "c16eeab416359d7f34a190b1836053cf",
    "name": "facebook",
    "chats_count": 0
}
```


#### Get an application: `GET /applications/:application_number`

##### Successful Response

```
{
    "token": "c16eeab416359d7f34a190b1836053cf",
    "name": "facebook",
    "chats_count": 0
}
```


#### Get all applications: `GET /applications`

##### Successful Response

```
[
    {
        "token": "bf07c9ac8ee0d820624e1d946a8687b5",
        "name": "instagram",
        "chats_count": 1
    },
    {
        "token": "c16eeab416359d7f34a190b1836053cf",
        "name": "facebook",
        "chats_count": 0
    }
]
```


#### Create a chat: `POST /applications/:application_token/chats`

##### No body needed for creating a chat

##### Successful Response

```
{
    "number": 2
}
```


#### Get a specific chat in an application: `GET /applications/:application_token/chats/:chat_number`

##### Successful Response

```
{
    "number": 1,
    "application_id": 1,
    "messages_count": 2
}
```
#### 404 Response: Application not found

```
{
    "error": "Application not found"
}
```


#### Get all chats in an application: `GET /applications/:application_token/chats`

##### Successful Response

```
[
    {
        "number": 1,
        "application_id": 1,
        "messages_count": 2
    },
    {
        "number": 2,
        "application_id": 1,
        "messages_count": 0
    }
]
```


#### Create a message: `POST /applications/:application_token/chats/:chat_number/messages`

##### Sample Body
```
{
    "body": "hey there!"
}
```

##### Successful Response

```
{
    "number": 2
}
```
#### 404 Response: Application not found || Chat not found


#### Update a message body: `POST /applications/:application_token/chats/:chat_number/messages/:message_number`

##### Sample Body
```
{
    "body": "hello buddy",
    "number": 1,
    "id": 1
}
```

##### Successful Response

```
{
    "number": 2
}
```

#### 404 Response: Application not found || Chat not found


#### Get a specific message in a chat: `GET /applications/:application_token/chats/:chat_number/messages/:message_number`

##### Successful Response

```
{
    "chat_id": 1,
    "body": "hello buddy",
    "number": 1,
}
```
#### 404 Response: Application not found || Chat not found

```
{
    "error": "Application not found"
}
```


#### Get all messages in a chat: `GET /applications/:application_token/chats/:chat_number/messages`

##### Successful Response

```
[
    {
        "number": 1,
        "body": "hello buddy",
    },
    {
        "number": 2,
        "body": "hey there!",
    }
]
```


#### Search messages in a specific chat: `GET /applications/:application_token/chats/:chat_number/messages/search?body={bosy_to_search}`

##### Successful Response

```
[
    {
        "number": 1,
        "body": "hello buddy",
    },
    {
        "number": 2,
        "body": "hey there!",
    }
]
```

##### 400 Response: body isn't provided in the query params
```
{
    "error": "Body parameter required for searching"
}
```


## Technologies
  
  - **Backend Server**: Ruby on Rails
  - **Database**: SQLite
  - **Text Search**: ElasticSearch
  - **Queuing System**: SideKiq
  - **Containarization**: Docker


## Challenges and Future Enhancements

#### MySQL
- MySQL was challenging to setup, encountered `mysql client is missing` error, when attempted to include `libmysqlclient-dev` in the docker file, got `not a package error` >> that was solved by including `default-libmariadb-dev` instead
- After MySQL container run successfully, a connection couldn't be established to it, found it to be a common problem >> Still working on the fix that's why SQLite was used for the PoC instead

#### Creating Messages in Batches
- The job can be found under `app/jobs` but calling it from the controller was challenging as the message object wasn't ready before the object was created in the DB (id was missing) >> still looking into the best way to do it

#### Indexing the Messages in ElasticSearch
- Messages were indexed fine while running the server manually (without Docker) but it seems to not run in Docker, even though `bin/rails searchkick:reindex CLASS=Message` is included in the Docker Compose file >> still looking into it

#### Running the application in `production` environment
- While it might seem trivial to run the application in `development` environment, the default setup provided by Rails sets the application to run in `production` environment which adds extra security measures such as forcing SSL mode `config.force_ssl = true`, which prevented the app (and any server running locally) from running properly as the server opened in `https` instead of `http` that was difficult to debug and trace but was solved by deleting the domain security measures in the browser for `localhost` each time the server started from here: chrome://net-internals/#hsts


#### Other Enhancements
- More background jobs could be created (ex: to calculate and write the messages_count and chats_count to the DB)
- Redis can be utilized to cache the application data instead of hitting the DB each time to get applications, chats and messages
