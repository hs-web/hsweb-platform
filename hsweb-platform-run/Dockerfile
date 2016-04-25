FROM java:8

COPY target/hsweb-platform-run-1.0-SNAPSHOT.jar /app.jar
EXPOSE 8088
ENTRYPOINT ["java","-jar","/app.jar"]