#!/bin/bash

mkdir -p lib/{core/{constants,utils,theme},data/{models,services,repositories},features/{auth/{data,domain,presentation},training_plan,data_logger,step_tracker,reminders,voice_coach},widgets,config/{routes,firebase}}

touch lib/main.dart

echo "Flutter folder structure created successfully ✅"
