---
show: true
date: 2023-05-01
name: Bayesian Multi-View Gaze Estimation
photo: /assets/images/projects/multiview_gaze.png
description: Developed an uncertainty-aware multi-view gaze estimation framework that dynamically selects informative camera views for robust gaze prediction. The method uses a Bayesian neural network to estimate the confidence of each face view, while a shared gaze backbone extracts view-specific visual features. These confidence scores are then used for soft feature selection before a final MLP predicts the gaze direction. To improve cross-view reliability, the framework also applies a multi-view consistency loss by transforming predictions from different camera coordinate systems into a shared reference space.
---


