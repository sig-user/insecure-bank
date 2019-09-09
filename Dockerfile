FROM tomcat:jre10

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH

RUN mkdir -p "$CATALINA_HOME"

WORKDIR $CATALINA_HOME

RUN chgrp -R 0 $CATALINA_HOME && chmod -R g+rw $CATALINA_HOME && find $CATALINA_HOME -type d -exec chmod g+x {} + && rm -rf /usr/local/tomcat/webapps/ROOT

COPY target/insecure-bank.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
