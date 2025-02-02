[<p align="center"><img src="./main_icon.png" width="120"/></p>](image.png)

# PLS-SEM Mobile Application POC

This is a *Proof-of-Concept (POC)* mobile application for running *Partial Least Squares Structural Equation Modeling (PLS-SEM)* on mobile devices. The app project is developed using Flutter, which is designed for deployment on both Android and iOS platforms.

The app is optimized for *tablet devices* to provide the best user experience (UX). While it can also be used on smartphones, the functionality might be limited.

## Authors

We are a group of students from the **Vietnamese-German University** in Ho Chi Minh City, Vietnam, enrolled in a joint Master's program with **Heilbronn University**, Germany:
 - **Van Hung NGUYEN**, email: 20223013@student.vgu.vn
 - **Hai Duong NGUYEN**, email: 20223008@student.vgu.vn

This project was developed as part of the **Management Science** module taught by **Dr. Hai Dung DINH**, Lecturer and Academic Coordinator at the Vietnamese-German University.

## Want to test?

We highly appreciate all feedback and contributions to enhance our software. If you are interested in testing our build(s), **please contact us using the email addresses provided above**. Please include the email address you use to access the Google Play Store and/or iCloud in your message.

You will therefore receive an invitation to participate in our closed testing program via *Google Play Testtrack* and/or *TestFlight*.


## Brief Description

This project practically implements the tasks of **Partial Least Squares Structural Equation Modeling (PLS-SEM)** as outlined [here](https://sem-in-r.github.io/seminr/#1_Introduction).

This mobile application serves as a front-end for a set of backend APIs developed using R code. The backend provides the necessary functions for calculation and returns the results to the app. The source code for the backend can be accessed at this link.

### User Workflow

The primary user flow involves:

1. **Data Input**: Users input a dataset in CSV format from their device's memory.
2. **Model Specification**: Users define the measurement model and structural model.
3. **Analysis Execution**: The app utilizes the input data and models to perform various PLS-SEM tasks.

### Core Functionality

The app automates most PLS-SEM tasks based on the provided data and model specifications. 

Certain tasks, such as convergent validity analysis for formative models, moderation analysis, mediation analysis, and predictive model comparison, may however require additional user inputs.


## Status 

Based on the document mentioned above, the PLS-SEM processes that are supported in the app include:


### Chapter 3: Model set up

- Create a measurement model ([link](https://sem-in-r.github.io/seminr/#232_Create_a_measurement_model))
- Create a structural model ([link](https://sem-in-r.github.io/seminr/#233_Create_a_structural_model))
- Estimating the model (link)
- Summarizing the model
- Bootstrapping the model

### Chapter 4: Evaluation of reflective measurement models

- Indicator reliability 
- Internal consistency reliability
- Convergent validity
- Discriminant validity

### Chapter 5: Evaluation of formative measurement models
- Model setup and measurement details
- Estimating and bootstrapping the model
- Reflective Measurement Model Evaluation
- Convergent validity with redundancy models 
- Indicator collinearity
- Significance and relevance of the indicator weights

### Chapter 6: Evaluation of the structural model
- Collinearity issues
- Significance and relevance of the structural model relationships
- Explanatory power 
- Prediction power: Generate predictions
- Prediction power: Predictive model comparisons

### Chapter 7: Mediation analysis

### Chapter 8: Moderation analysis

## Indicators that can be computed and presented by the app: 

- `iterations` 
- `paths`
- `total_effects`  
- `total_indirect_effects`  
- `loadings`  
- `weights` 	 
- `validity` 	 
- `reliability` 	 
- `composite_scores` 	 
- `vif_antecedents` 	 
- `fSquare` 	 
- `descriptives` 	 
- `it_criteria`
- `nboot`
- `bootstrapped_paths` 	 
- `bootstrapped_weights` 	 
- `bootstrapped_loadings` 	 
- `bootstrapped_HTMT` 	 
- `bootstrapped_total_paths` 	

## Instructions

### Dataset Upload

1. **Open the app** and tap the *"Add Dataset"* button on the home screen.
2. **Specify the delimiter**: Choose whether your CSV dataset uses a *comma (,)* or *semicolon (;)* as the delimiter.
3. **Select and upload**: Tap the *"Upload File"* button to select and upload your CSV file from your device's storage.

The app will then display the number of rows and columns detected in your dataset. You can also preview the first ten rows of the data to verify the upload.

### Prepare Measurement and Structural models

> [!TIP]
>
> If you are using the provided *"Corporate Reputation Data.csv"* dataset, the app automatically suggests initial Measurement and Structural models for your convenience.

1. **Navigate to the Measurement Model**: Scroll down to the Measurement Model section on the Data Import screen.
2. **Add a Composite**: Tap the "+" button to create a new composite.
3. **Edit Composite**: A drawer will appear on the right side of the screen, allowing you to edit the composite details. *Please refer to [this link](https://sem-in-r.github.io/seminr/#232_Create_a_measurement_model) for detailed information on creating and understanding composites.*
4. **Save Composite**: Tap **"Save"** to save the edited composite. The saved composite will appear in the list under the Measurement Model section.
5. **Delete Composite**: To delete a composite, tap on it again, and the **"Delete"** button will appear at the bottom of the drawer.

Repeat these steps to define the Structural Model.

> **Path Weighting:**
>
> You can choose to use **"path weighting"** to estimate the PLS model. For more information on path weighting, please refer to [this link](https://sem-in-r.github.io/seminr/#234_Estimating_the_model).

### Save the Measurement and Structural models

1. On the **Data Import** screen, tap the **"Done"** button located in the top-right corner.
2. The app will prompt you to save the current dataset setup. Tap **"Save"** to proceed. Alternatively, you can tap **"Cancel"** or **"Discard"** to cancel the setup and start over.

### Explore PLS-SEM tasks 

Once you have successfully defined your dataset, measurement model, and structural model, you can proceed to explore the various tasks involved in PLS-SEM evaluation as mentioned in **Status** part above.

These tasks are automated by interacting with a backend system, which performs the necessary calculations and presents the results directly within the app.

Please note that some tasks may take longer to complete than others due to the complexity of the calculations and the underlying data structures.

### Special tasks requiring additional user inputs

#### Convergent Validity of Formative Models

> For guidance on **redundancy models**, please refer to this chapter in the document [here](https://sem-in-r.github.io/seminr/#42_Convergent_validity).

> You can load the predefined list of redundancy models as in the document by pressing on **"Load Predefined"**.

1. **Add a Redundancy Model**: Tap the **"+ Add"** button to create a new redundancy model.
2. **Edit Specifications**: A drawer will appear on the right side of the screen, allowing you to edit the specifications for the new model.
3. **Calculate Results**: After tapping **"Save"**, the app will automatically call the backend API to perform the necessary calculations.

#### Make and compare Predictive models

1. Press on **"Predictive model comparisons"** under "Evaluation of structural model" section.
2. You will see the same UI as in the model setup screen as mentioned in **Data Import** screen. But the difference in this part is to make *multiple* Structural Models.
3. Press on **"+ Add more Structural Model"** to add a new structural model.
4. Compose and add more paths for each structural model as you need.
5. Press on **"Start Compare"** to make comparison between each Structural Model.

#### Mediation Analysis

> For a detailed explanation of **mediation analysis**, please refer to this chapter in the document [here](https://sem-in-r.github.io/seminr/#6_Mediation_analysis_(Chapter_7)).

To perform a mediation analysis:

1. **Navigate to the "Mediation Analysis"** section and tap the "Mediation Analysis" button.
2. **Add a Mediation Path**: Tap the "+ Add" button to specify the effect you want to analyze.
3. **Define the Mediation Path**: Select the "From," "To," and "Through" variables using the respective combo boxes.
4. **Calculate and View Results**: Tap "Calculate." The app will analyze the specified effect and display the results on the screen after processing.

---

Vietnamese-German University, Ho Chi Minh City, Vietnam, February 2025

