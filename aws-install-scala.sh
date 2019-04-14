#
# aws-install-scala.sh
#

#
# Product versions 
#
# scalaVersion 2.12.7
# sbtVersion 1.2.8
# sparkVersion 2.4.0
# javaVersion 1.8.0_191

#
# Open ssh tunnel to AWS cluster from Macbook Pro terminal
#
ssh -i ~/EMR.pem hadoop@ec2-52-206-224-115.compute-1.amazonaws.com


#
# Define environmental variables
#
export HADOOP_HOME=/usr/lib/hadoop/
export SPARK_HOME=/usr/lib/spark/
export PATH=$PATH:/opt/sbt/bin

#
#  get sbt 
#
wget https://github.com/sbt/sbt/releases/download/v1.2.8/sbt-1.2.8.tgz

#
# Create sbt source directories
#
mkdir $HOME/src
mkdir $HOME/src/main
mkdir $HOME/src/main/scala
mkdir $HOME/src/main/scala/spr

mkdir $HOME/src/test
mkdir $HOME/src/test/scala

#
# make sure project directory contains build properties file with current sbt version
#

#
# Unload and install sbt
#
tar xf sbt-1.2.8.tgz
sudo mv sbt /opt

#
# Create project directories
#
sbt new sbt/scala-seed.g8

#
# you will be prompted for the project here
#
enter project name here

#
# check that project directories are created
#
ls -la 
find .

#
# setup link here to the jars 
#
sudo find / -name "spark-core*jar"
sudo ln -s /usr/lib/spark/jars lib

#
# check spark shell version
# 
spark-shell --version

#
# Run a simple program in spark-shell
#
spark-shell
import org.apache.spark.sql.SparkSession

object Hello {
  def main(args: Array[String]) {
  println("Hello")
  }
}
Hello.main(null)

#
# Create an empty sbt build directory
#
mkdir $HOME/spr-build
cd $HOME/spr-build
touch build.sbt

#
# Start the sbt shell  then exit
#
sbt 
exit

#
# Compile a project
#
sbt compile

#
# Add a simple project build file
#
rm $HOME/spr-build/build.sbt
cat > $HOME/spr-build/build.sbt <<- "EOF"

organization := "example"
scalaVersion := "2.12.7"
version := "0.1.0-SNAPSHOT"

val sparkVersion = "2.4.0"

lazy val hello = (project in file("."))
  .settings(
    name := "Hello",
    libraryDependencies += "org.scalatest" %% "scalatest" % "3.0.5" % Test,
    libraryDependencies += "org.apache.spark" %% "spark-core" % "2.4.0",
    libraryDependencies += "org.apache.spark" %% "spark-sql" % "2.4.0",
    libraryDependencies += "org.apache.spark" %% "spark-mllib" % "2.4.0",
    libraryDependencies += "org.apache.spark" %% "spark-streaming" % "2.4.0",
    )
EOF

#
# Create a simple program
#
rm $HOME/spr/src/main/scala/example/Hello.scala
cat > $HOME/spr/src/main/scala/example/Hello.scala <<- "EOF"

package example

import org.apache.spark.sql.SparkSession

object Hello {
  def main(args: Array[String]) {
  println("Hello")
  }
}
EOF

#
# Use the reload command to reload the build file
#
sbt compile

#
# Check to see if jar file was created
#
ls -la /home/hadoop/spr/src/main/scala/example/target/scala-2.12/example_2.12-0.1.0-SNAPSHOT.jar

#
# Run the program
#
sbt run

#
# Add test scripts
#
cat > $HOME/src/test/scala/HelloSpec.scala <<- "EOF"
import org.scalatest._

class HelloSpec extends FunSuite with DiagrammedAssertions {
  test("Hello should start with H") {
    // Hello, as opposed to hello
    assert("Hello".startsWith("H"))
  }
}sbt
EOF

#
# Submit a simple program to run
#
spark-submit \
  --master local \
  --class "example.Hello" \
  /home/hadoop/spr/src/main/scala/example/target/scala-2.12/example_2.12-0.1.0-SNAPSHOT.jar \
  null


spark-submit --master "local[*]" --class pl.japila.spark.SparkMeApp target/scala-2.12/sparkme-project_2.12-1.0.jar build.sbt
#
# end of file
#
