package com.example.pls_flutter.java_supports;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import javax.script.*;
import org.renjin.script.*;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.r.RUtils;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.stream.Collectors;

public class MyJavaConnector {
    private String message;

    public MyJavaConnector(String message) {
        this.message = message;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public void displayMessage() {
        System.out.println("Message from Java: " + message);
    }

    public void evaluateRJava() throws ScriptException, FileNotFoundException {
        // create a script engine manager:
        RenjinScriptEngineFactory factory = new RenjinScriptEngineFactory();
        // create a Renjin engine:
        ScriptEngine engine = factory.getScriptEngine();

        String fileName = "app/src/main/java/gradle_local_project/Java/2_model_setup.R";
//        String fileName = "app/src/main/java/gradle_local_project/Java/3_reflective_measurement_models.R";
//        String fileName = "app/src/main/java/gradle_local_project/Java/4_formative_measurement_models.R";
//        String fileName = "app/src/main/java/gradle_local_project/Java/5_Evaluation_structural_model.R";
//        String fileName = "app/src/main/java/gradle_local_project/Java/5_5_Predictive_model_comparisons.R";
//        String fileName = "app/src/main/java/gradle_local_project/Java/6_Mediation_analysis.R";
//        String fileName = "app/src/main/java/gradle_local_project/Java/7_Moderation_analysis.R";

        if (fileName.isEmpty() == false) {
            // Evaluate external R script
            Object fromFile = engine.eval(new java.io.FileReader(fileName));
            String data = fromFile.toString();
            System.out.println(data);
        } else {
            // Evaluate R inline
            engine.eval("library(e1071)");
            engine.eval("library(\"com.mycompany:extensionsdemo\")");
            engine.eval("data(iris)");
            engine.eval("print(head(iris))");
            engine.eval("svmfit <- svm(Species~., data=iris)");

            engine.eval("df <- data.frame(x = 1:10, y = rnorm(n = 10))");

            engine.eval("mean <- meantrim(1:10)");
            engine.eval("print(mean)");

            engine.eval("print(lm(y ~ x, df))");
            // Use CRAN and BioConductor packages
//        engine.eval("ggplot2::qplot(x, y, data = df)");
        }
    }

    public String getMeanScriptContent() throws IOException, URISyntaxException {
//        URL rScriptUri = MyJavaConnector.class.getResource("RScript") ;
//        URL rScriptUri = ExchangeInterceptor.class.getClassLoader().getResource("2_model_setup.R") ;
        URI rScriptUri = RUtils.class.getClassLoader().getResource("app/src/main/java/gradle_local_project/Java/2_model_setup.R").toURI();

        Path inputScript = Paths.get(rScriptUri);
        return Files.lines(inputScript).collect(Collectors.joining());
//        assert rScriptUri != null;
//        return rScriptUri.toString();
    }
}
