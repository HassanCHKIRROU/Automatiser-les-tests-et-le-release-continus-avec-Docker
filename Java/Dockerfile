
# STAGE 1 : build avec Gradle + JDK complet

FROM eclipse-temurin:21-jdk-alpine AS build

WORKDIR /build

COPY gradlew ./
COPY gradle ./gradle
COPY build.gradle settings.gradle ./
COPY src ./src

# Normalise les fins de ligne (CRLF -> LF) puis rend le script exécutable.
# Nécessaire car le fichier gradlew a été committé avec des fins de ligne
# Windows (CRLF), ce que le shell Linux du conteneur ne sait pas interpréter.
RUN sed -i 's/\r$//' gradlew && chmod +x gradlew

RUN ./gradlew clean bootWar -x test --no-daemon







# STAGE 2 : image finale, juste un JRE pour exécuter le .war

FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

COPY --from=build /build/build/libs/workshop-organizer-0.2.4.war app.war

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.war"]