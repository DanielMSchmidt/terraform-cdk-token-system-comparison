import { Construct } from "constructs";
import { App, TerraformStack } from "cdktf";
import { Container, Image, DockerProvider } from "./.gen/providers/docker";

class MyStack extends TerraformStack {
  public readonly dockerImage: Image;

  constructor(scope: Construct, name: string) {
    super(scope, name);

    new DockerProvider(this, "provider", {});

    this.dockerImage = new Image(this, "nginxImage", {
      name: "nginx:latest",
      keepLocally: false,
    });

    new Container(this, "nginxContainer", {
      image: this.dockerImage.latest,
      name: "tutorial",
      ports: [
        {
          internal: 80,
          external: 8000,
        },
      ],
    });
  }
}

const app = new App();
new MyStack(app, "demo-cdktf-ts-docker");
app.synth();
