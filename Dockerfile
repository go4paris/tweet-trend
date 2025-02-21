FROM openjdk:21
COPY target/demo-workshop-2.1.4.jar ttrend.jar 
ENTRYPOINT [ "java", "-jar", "ttrend.jar" ]