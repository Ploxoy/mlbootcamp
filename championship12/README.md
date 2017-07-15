������� �� 9 ����� (68 ������)
---------------------

### ������ ������
������� ��� �������������� ������: ap_lo < 50 | ap_lo > 140 | ap_hi < 70 | ap_hi > 210. ������� ��������. � ����������� �� �������� "�������� �� 10, �������� �� 10". ����� ������� ap_hi < ap_lo.
��, ������� �� ������� ��� ����������, ������������ �� ������. ��� ����� ����������� ������� ���������.
<a href="https://github.com/tyamgin/mlbootcamp/blob/master/championship12/fix.R">���� �����������.</a>

### ���������
������������ 15 ������� �� 7 ������ � ������ ��������. ������� ������, ��� ������ stratified.

### ���������� ���������
smoke = 0
alco = 0
active = 1

### ������
Xgboost � LightGBM. ������ ������� ��������������.

#### Xgboost:
##### ���������
  max_depth=4 
  gamma=0.9
  lambda=1
  alpha=10
  eta=0.075
  subsample=0.9
  colsample_bytree=0.7
  min_child_weight=10
  nrounds=175
  num_parallel_tree=1

##### ����
age
gender
ap_hi
ap_lo
cholesterol
gluc
smoke
alco
active
cholesterol ? 1 & gluc ? 1
lol2 = cholesterol - gluc
lol3 = cholesterol + gluc + 3*smoke + alco - 4*active
<a href="http://halls.md/race-body-fat-percentage/">fat</a> = 1.39 * weight / (height/100)^2 + 0.16 * age / 365 - 10.34 * gender - 9 
smoke ? 0 & alco ? 0
gender ? 1 & cholesterol ? 2
log(height) / log(weight)
log(age) * height^2
gender ? 1 | gluc ? 1
gender ? 0 & cholesterol ? 3
smoke ? 0 | active ? 0
log(ap_hi) * log(ap_lo)

#### LightGBM:

##### ���������

  num_leaves=15
  nrounds=55
  learning_rate=0.223558
  max_depth=4
  lambda_l2=10
  feature_fraction=0.746088
  min_data_in_leaf=382
  bagging_fraction=0.910187

##### ����
age
gender
ap_hi
ap_lo
cholesterol
gluc
smoke
alco
cholesterol ? 1 & gluc ? 1
lol2 = cholesterol - gluc
log(age) * height^2
gluc ? 3 & active ? 0
cholesterol ? 1 & alco ? 0
gender ? 0 & active ? 0
gender ? 1 | smoke ? 1
sqrt(height) / log(weight)
gender ? 1 | gluc ? 3

���� �������� ����������: ��������� ���������� ��� ��������. �������� ������������� �� 5 ������ * 7 �������. ������ ������, ����� �� �������������.
