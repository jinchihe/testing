{

  // Build a multi-line container command.
  // Input is a list of lists. Where each list describes a command to be run.
  // e.g
  // [ ["echo", "command-one"], ["echo", "command-two"]]
  // Output is a list containing a shell command to run them
  // e.g.
  // ["/bin/sh", "-xc", "echo command-one; echo command-two"]
  buildCommand:: function(items)
    ["/bin/sh", "-xc"] +
    [std.join("; ",
      std.map(
        function(c) std.join(" ", c),
        items,
      )
  )],

  jobSpec:: {
      "template": {
        "spec": {
          "containers": [
            {
              command: $.buildCommand([[
                "/usr/local/bin/checkout.sh",
                "/src",
              ],             
              [
                "python",
                "-m",
                "kubeflow.testing.cleanup_ci",
                "all",
                "--delete_script=/src/kubeflow/kubeflow/scripts/gke/delete_deployment.sh",
              ],
              ]), 
              "image": "gcr.io/kubeflow-ci/test-worker/test-worker:v20190116-b7abb8d-e3b0c4", 
              "name": "label-sync",
              env: [
                {
                  name: "REPO_OWNER",
                  value: "kubeflow",                  
                },
                {
                  name: "REPO_NAME",
                  value: "testing",                  
                },
                {
                  // TODO(jlewi): Stop setting PULL_NUMBER once the PR is merged.
                  // We had to set the PR number because when we initially created the
                  // job we had some changes to cleanup_ci.py that were part of the PR
                  // committing the job.
                  name: "PULL_NUMBER",
                  value: "300",
                },
                {
                  name: "PYTHONPATH",
                  value: "/src/kubeflow/testing/py",
                },
                {
                  name: "EXTRA_REPOS",                  
                  value: "kubeflow/kubeflow@HEAD",
                },
                {
                  name: "GOOGLE_APPLICATION_CREDENTIALS",
                  value: "/secret/gcp-credentials/key.json",
                },              
              ],
              "volumeMounts": [                
                {
                  name: "gcp-credentials",
                  mountPath: "/secret/gcp-credentials",
                  readOnly: true
                },
              ]
            }
          ], 
          "restartPolicy": "Never", 
          "volumes": [
            {
              name: "gcp-credentials",
              secret: {
                secretName: "kubeflow-testing-credentials",
              },
            },            
          ]
        }
      }
    },
}