#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Welcome
echo -e "\n~~~~~Welcome to Pirate Salon~~~~~~\n"

# Main_Services
MAIN_SERVICES() {
if [[ $1 ]]
  then
    echo -e "\n$1"
fi
echo -e "\nWhat service would you like to do today?\n"
SERVICE_LIST=$($PSQL "select * from services order by service_id")
echo "$SERVICE_LIST" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  
  # get service
  read SERVICE_ID_SELECTED

  # if not a valid service input
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
    MAIN_SERVICES "Please enter a valid number."
    else
    SERVICE_AVAILABLE=$($PSQL "select service_id from services where service_id = '$SERVICE_ID_SELECTED'")
    
    # if service not available
    if [[ -z $SERVICE_AVAILABLE ]]
      then
      MAIN_SERVICES "Sorry, service is not available at the moment."
      else
        # get customer phone
        echo -e "\nWhat is your phone number?"
        read CUSTOMER_PHONE

        CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
        SERVICE_NAME=$($PSQL "select name from services where service_id = '$SERVICE_ID_SELECTED'")
        
      # customer not exist
      if [[ -z $CUSTOMER_NAME ]]
        then
        # get customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        # add new customer
        INSERT_NEW_CUSTOMER=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi

      # get service time
      echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
        read SERVICE_TIME

      # get customer id
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
      if [[ $SERVICE_TIME ]]
        then
        # insert appointment
        INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME." 
      fi        
    fi
  fi
}
MAIN_SERVICES

