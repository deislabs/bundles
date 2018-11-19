const { events, Job, Group } = require("brigadier")

const projectName = "bundles"

function test(e, project) {
  var test = new Job(`${projectName}-test`, "brigade.azurecr.io/deis/duffle:latest");
  test.imagePullSecrets = ["brigade-acr-pull-secret"]

  test.tasks = [
    "apk add --update --no-cache make",
    "cd /src",
    "SHELL=/bin/sh make test-functional-local"
  ];

  return test
}

// Here we can add additional Check Runs, which will run in parallel and
// report their results independently to GitHub
function runSuite(e, p) {
  runTests(e, p).catch(e => {console.error(e.toString())});
}

// runTests is a Check Run that is ran as part of a Checks Suite
function runTests(e, p) {
  console.log("Check requested")

  // Create Notification object (which is just a Job to update GH using the Checks API)
  var note = new Notification(`tests`, e, p);
  note.conclusion = "";
  note.title = "Run Tests";
  note.summary = "Running the test targets for " + e.revision.commit;
  note.text = "Ensuring all tests all pass."

  // Send notification, then run, then send pass/fail notification
  return notificationWrap(test(e, p), note)
}

// A GitHub Check Suite notification
class Notification {
  constructor(name, e, p) {
    this.proj = p;
    this.payload = e.payload;
    this.name = name;
    this.externalID = e.buildID;
    this.detailsURL = `https://azure.github.io/kashti/builds/${ e.buildID }`;
    this.title = "running check";
    this.text = "";
    this.summary = "";

    // count allows us to send the notification multiple times, with a distinct pod name
    // each time.
    this.count = 0;

    // One of: "success", "failure", "neutral", "cancelled", or "timed_out".
    this.conclusion = "neutral";
  }

  // Send a new notification, and return a Promise<result>.
  run() {
    this.count++
    var j = new Job(`${ this.name }-${ this.count }`, "deis/brigade-github-check-run:latest");
    j.env = {
      CHECK_CONCLUSION: this.conclusion,
      CHECK_NAME: this.name,
      CHECK_TITLE: this.title,
      CHECK_PAYLOAD: this.payload,
      CHECK_SUMMARY: this.summary,
      CHECK_TEXT: this.text,
      CHECK_DETAILS_URL: this.detailsURL,
      CHECK_EXTERNAL_ID: this.externalID
    }
    return j.run();
  }
}

// Helper to wrap a job execution between two notifications.
async function notificationWrap(job, note, conclusion) {
  if (conclusion == null) {
    conclusion = "success"
  }
  await note.run();
  try {
    let res = await job.run()
    const logs = await job.logs();

    note.conclusion = conclusion;
    note.summary = `Task "${ job.name }" passed`;
    note.text = note.text = "```" + res.toString() + "```\nTest Complete";
    return await note.run();
  } catch (e) {
    const logs = await job.logs();
    note.conclusion = "failure";
    note.summary = `Task "${ job.name }" failed for ${ e.buildID }`;
    note.text = "```" + logs + "```\nFailed with error: " + e.toString();
    try {
      return await note.run();
    } catch (e2) {
      console.error("failed to send notification: " + e2.toString());
      console.error("original error: " + e.toString());
      return e2;
    }
  }
}

function dockerPublish(project, gitTag, imageTag) {
  const publisher = new Job(`${projectName}-docker-publish`, "docker");
  let dockerRegistry = project.secrets.dockerhubRegistry || "docker.io";
  let dockerOrg = project.secrets.dockerhubOrg || "cnab";

  publisher.docker.enabled = true;
  publisher.tasks = [
    "apk add --update --no-cache make",
    `cd /src && git checkout ${gitTag}`,
    `docker login ${dockerRegistry} -u ${project.secrets.dockerhubUsername} -p ${project.secrets.dockerhubPassword}`,
    `DOCKER_REGISTRY=${dockerOrg} VERSION=${imageTag} make docker-build-all docker-push-all`,
  ];

  return publisher;
}

events.on("exec", (e, p) => {
  test(e, p).run()
})

events.on("check_suite:requested", runSuite)
events.on("check_suite:rerequested", runSuite)
events.on("check_run:rerequested", runSuite)

// Although a GH App will trigger 'check_suite:requested' on a push to master event,
// it will not for a tag push, hence the need for this handler
events.on("push", (e, p) => {
  let release = false;
  let gitTag = "";
  let imageTag = "";

  if (e.revision.ref.includes("refs/heads/master")) {
    release = true;
    gitTag = "master"
    imageTag = "latest"
  } else if (e.revision.ref.startsWith("refs/tags/")) {
    release = true;
    let parts = e.revision.ref.split("/", 3)
    gitTag = parts[2]
    imageTag = gitTag
  }

  if (release) {
    dockerPublish(p, gitTag, imageTag).run()
  }
})

events.on("release", (e, p) => {
  /*
   * Expects JSON of the form {'tag': 'v1.2.3'}
   */
  payload = JSON.parse(e.payload)
  if (!payload.tag) {
    throw error("No tag specified")
  }

  dockerPublish(project, payload.tag, payload.tag).run()
})
