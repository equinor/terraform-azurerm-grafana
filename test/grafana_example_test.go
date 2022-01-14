package test

import (
	"fmt"
	"net"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestGrafanaExample(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/grafana-example",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	appServiceDefaultSiteHostname := terraform.Output(t, terraformOptions, "app_service_default_site_hostname")

	tcpAddr, _ := net.ResolveTCPAddr("tcp4", fmt.Sprintf("%s:443", appServiceDefaultSiteHostname))

	retry.DoWithRetry(t, "Dial TCP address", 15, 5*time.Second, func() (string, error) {
		conn, err := net.DialTCP("tcp", nil, tcpAddr)
		if err != nil {
			return "", err
		}
		defer conn.Close()
		return "", nil
	})
}
