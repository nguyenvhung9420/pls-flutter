import 'package:pls_flutter/presentation/models/pls_task_view.dart';

class MyHomeViewModel {
  final Map<String, String> loginCredentials = {"username": "hungnguyen_pls_sem", "password": "secret"};

  final List<PlsTask> plsTaskList = [
    PlsTask(
      taskCode: 'model_summary',
      name: 'Model Summary',
      description: 'Serve as basis for the assessment of the measurement and structural model',
    ),
    PlsTask(
      taskCode: 'model_bootstrap_summary',
      name: 'Bootstrap Summary',
      description: 'Perform bootstrapping to estimate standard errors and compute confidence intervals',
    ),
    PlsTask(
      taskCode: 'indicator_reliability',
      name: 'Indicator reliability',
      description: 'Indicator reliability can be calculated by squaring the loadings.',
    ),
    PlsTask(
      taskCode: 'internal_consistency_reliability',
      name: 'Internal consistency reliability',
      description: 'The extent to which indicators measuring the same construct are associated with each other',
    ),
    PlsTask(taskCode: 'convergent_validity', name: 'Convergent Validity', description: 'Description for Item 5'),
    PlsTask(taskCode: 'discriminant_validity', name: 'Discriminant Validity', description: 'Description for Item 5'),
    PlsTask(
        taskCode: 'evaluation_of_formative_basic',
        name: 'Model and measurement details',
        description: 'Model and measurement details'),
    PlsTask(
      taskCode: 'formative_indicator_collinearity',
      name: 'Indicator collinearity',
      description: 'Indicator collinearity',
    ),
    PlsTask(
      taskCode: 'formative_significance_relevance',
      name: 'Significance and relevance of the indicator weights',
      description: 'Significance and relevance of the indicator weights',
    ),
    PlsTask(
      taskCode: 'collinearity_issues',
      name: 'Collinearity issues',
      description:
          'To examine the VIF values for the predictor constructs we inspect the vif_antecedents element within the summary_corp_rep_ext object. ',
    ),

    // Significance and relevance of the structural model relationships;
    PlsTask(
      taskCode: 'structural_significance_relevance',
      name: 'Significance and relevance of the structural model relationships',
      description:
          'To evaluate the relevance and significance of the structural paths, we inspect the bootstrapped_paths element nested',
    ),

    // Explanatory power:
    PlsTask(
      taskCode: 'explanatory_power',
      name: 'Explanatory power',
      description:
          'To consider the model\'s explanatory power we analyze the R2 of the endogenous constructs and the f2 effect size of the predictor constructs. R2 and adjusted R2 can be obtained from the paths element',
    ),

    // Predictive power
    PlsTask(
        taskCode: 'predictive_power',
        name: 'Predictive power',
        description:
            'To evaluate the model\'s predictive power, we generate the predictions using the predict_pls() function'),

    //Predictive model comparisons :
    PlsTask(
      taskCode: 'predict_models_comparisons',
      name: 'Predictive model comparisons',
      description: 'Description',
    ),

    // Mediation analysis
    PlsTask(
        taskCode: 'mediation_analysis',
        name: 'Mediation analysis',
        description:
            'Mediation occurs when a construct, referred to as mediator construct, intervenes between two other related constructs'),

    // Moderation analysis
    PlsTask(
        taskCode: 'moderation_analysis',
        name: 'Moderation analysis',
        description:
            'Moderation describes a situation in which the relationship between two constructs is not constant but depends on the values of a third variable, referred to as a moderator variable'),

    // Formative Convergent Validity:
    PlsTask(
      taskCode: 'formative_convergent_validity',
      name: 'Convergent Validity',
      description: 'Convergent Validity',
    ),
  ];

  List<TaskGroup> taskGroups() => [
        TaskGroup('Model Setup', [
          plsTaskList[0],
          plsTaskList[1],
        ]),
        TaskGroup('Evaluation of reflective measurement models', [
          plsTaskList[2],
          plsTaskList[3],
          plsTaskList[4],
          plsTaskList[5],
        ]),
        TaskGroup('Evaluation of formative measurement models', [
          plsTaskList[6],
          plsTaskList[16],
          plsTaskList[7],
          plsTaskList[8],
        ]),
        TaskGroup('Evaluation of the structural model', [
          plsTaskList[9],
          plsTaskList[10],
          plsTaskList[11],
          plsTaskList[12],
          plsTaskList[13],
        ]),
        TaskGroup("Mediation analysis", [
          plsTaskList[14],
        ]),
        TaskGroup("Moderation analysis", [
          plsTaskList[15],
        ])
      ];
}
