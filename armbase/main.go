package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"

	"github.com/Azure/azure-sdk-for-go/services/resources/mgmt/2017-05-10/resources"
	"github.com/Azure/go-autorest/autorest"
	"github.com/Azure/go-autorest/autorest/azure/auth"
)

var (
	loc            string
	groupName      string
	template       []byte
	params         []byte
	deploymentName string
	action         string
)
var authorizer = authN()

func main() {
	subscriptionID := os.Getenv("AZURE_SUBSCRIPTION_ID")
	action = envOr("CNAB_ACTION", "install")
	loc = envOr("AZURE_LOCATION", "eastus")
	groupName = envOr("AZURE_RESOURCE_GROUP", "mytestgroup")
	deploymentName = envOr("CNAB_INSTALLATION_NAME", "testdep")

	switch action {
	case "install", "upgrade":
		install(subscriptionID)
	case "uninstall":
		uninstall(subscriptionID)
	}
}

func install(subscriptionID string) {
	if len(os.Args) != 3 {
		exitf("usage: armup TEMPLATE PARAMETERS: got %d args", len(os.Args))
	}

	var err error
	template, err = ioutil.ReadFile(os.Args[1])
	if err != nil {
		exitf("failed to read template file: %s", err)
	}

	params, err = ioutil.ReadFile(os.Args[2])
	if err != nil {
		exitf("failed to read parameters: %s", err)
	}
	params = []byte(os.ExpandEnv(string(params)))

	if err := createGroup(groupName, subscriptionID); err != nil {
		exitf("cannot create group: %s", err)
	}
	if err := createDeployment(groupName, deploymentName, subscriptionID); err != nil {
		exitf("cannot create deployment: %s", err)
	}
}

func uninstall(subscriptionID string) {
	destroyGroup(groupName, subscriptionID)
}

func envOr(varname, defaultVal string) string {
	if val, ok := os.LookupEnv(varname); ok {
		return val
	}
	return defaultVal
}

func exitf(format string, vals ...interface{}) {
	fmt.Fprintf(os.Stderr, format, vals...)
	fmt.Fprintln(os.Stderr, "")
	os.Exit(1)
}

func authN() autorest.Authorizer {
	authenticator, err := auth.NewAuthorizerFromEnvironment()
	if err != nil {
		exitf("could not get auth info: %s", err)
	}
	return authenticator
}

func createGroup(name, subID string) error {
	client := resources.NewGroupsClient(subID)
	client.Authorizer = authorizer
	_, err := client.CreateOrUpdate(context.TODO(), name, resources.Group{
		Location: &loc,
	})
	return err
}

func destroyGroup(name, subID string) error {
	client := resources.NewGroupsClient(subID)
	client.Authorizer = authorizer
	res, err := client.Delete(context.TODO(), name)
	if err != nil {
		return err
	}

	err = res.WaitForCompletionRef(context.TODO(), client.Client)
	fmt.Println(res.Status())
	return err
}

func createDeployment(group, dep, subID string) error {
	client := resources.NewDeploymentsClient(subID)
	client.Authorizer = authorizer

	tpl := map[string]interface{}{}
	parameters := map[string]interface{}{}

	if err := json.Unmarshal(template, &tpl); err != nil {
		return err
	}
	if err := json.Unmarshal(params, &parameters); err != nil {
		return err
	}

	deployment := resources.Deployment{
		Properties: &resources.DeploymentProperties{
			Template:   &tpl,
			Parameters: &parameters,
			Mode:       resources.Incremental,
		},
	}

	client.Validate(context.TODO(), group, dep, deployment)

	res, err := client.CreateOrUpdate(context.TODO(), group, dep, deployment)
	if err != nil {
		return err
	}
	err = res.WaitForCompletionRef(context.TODO(), client.Client)
	if err != nil {
		return err
	}
	response, err := res.GetResult(client)
	data, err := ioutil.ReadAll(response.Body)
	if err != nil {
		return err
	}
	fmt.Println(string(data))
	//fmt.Println(res.Status())
	return err
}
