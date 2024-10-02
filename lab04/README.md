# Usage

__note__: I lazily copy code + dockerfile from https://www.freecodecamp.org/news/how-to-dockerize-a-flask-app/, and add more stuffs like ignore files, etc.

also added port option


- build docker image:

``` bash
docker build -t flasktest .
```

- run docker container, inside container, flask will listen at port 3000. Map it to port 3000 of your host.

```bash
docker run -p3000:3000  flasktest
```

output should be:

```txt
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:3000
 * Running on http://172.17.0.2:3000
Press CTRL+C to quit
```


- access `http://localhost:3000` from your browser, or curl like below:

```txt
$ curl localhost:3000

<h1>Hello from Flask & Docker</h1>
```
