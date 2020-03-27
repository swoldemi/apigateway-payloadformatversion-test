package main

import (
	"context"
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

const unable = "Unable to find Content-Type"

// Handler is the Lambda function handler for the integration.
func Handler(ctx context.Context, event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Printf("Got request: %#v", event)
	val, ok := event.Headers["Content-Type"]
	if !ok {
		log.Println(unable)
		return events.APIGatewayProxyResponse{
			StatusCode: 400,
			Body:       unable,
		}, nil // No point in returning error to Lambda
	}

	body := fmt.Sprintf("Got Content-Type: %s", val)
	log.Println(body)
	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       body,
	}, nil
}

func main() {
	lambda.Start(Handler)
}
