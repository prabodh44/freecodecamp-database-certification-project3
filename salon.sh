#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo "~~~~~ MY SALON ~~~~~"
echo
echo "Welcome to My Salon, how can I help you?"

# Keep repeating until user selects a valid service
while true
do
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  NUM_OF_OPTIONS=$($PSQL "SELECT COUNT(*) FROM services;")
  NUM_OF_OPTIONS=$(echo "$NUM_OF_OPTIONS" | xargs)

  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] || [[ $SERVICE_ID_SELECTED -lt 1 ]] || [[ $SERVICE_ID_SELECTED -gt $NUM_OF_OPTIONS ]]
  then
    echo
    echo "I could not find that service. What would you like today?"
    echo
  else
    break
  fi
done

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
SERVICE_NAME=$(echo "$SERVICE_NAME" | xargs)

# Ask customer for phone number
echo
echo "What's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | xargs)

# If customer does not exist
if [[ -z $CUSTOMER_NAME ]]
then
  echo
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  $PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
fi

# Ask for service time
echo
echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
CUSTOMER_ID=$(echo "$CUSTOMER_ID" | xargs)

$PSQL "INSERT INTO appointments(customer_id, service_id, time)
       VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

echo
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
