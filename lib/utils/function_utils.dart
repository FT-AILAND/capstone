import 'dart:core';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'dart:math' as m;

List<List<double>> findXyz(
    List<int> indexList, Map<PoseLandmarkType, PoseLandmark> landmarks) {
  List<List<double>> list = [];
  for (int i = 0; i < 3; i++) {
    // !를 사용해도 될까
    PoseLandmark? poseLandmark =
        landmarks[PoseLandmarkType.values[indexList[i]]];
    double x = poseLandmark!.x;
    double y = poseLandmark.y;
    double z = poseLandmark.z;
    List<double> iXyz = [x, y, z];
    list.add(iXyz);
  }
  return list;
}

double calculateAngle3D(List<List<double>> listXyz, {int direction = 1}) {
  List<double> a = listXyz[0];
  List<double> b = listXyz[1];
  List<double> c = listXyz[2];
  double externalZ =
      (b[0] - a[0]) * (b[1] - c[1]) - (b[1] - a[1]) * (b[0] - c[0]);

  List<double> baVector = customExtraction(b, a);
  List<double> bcVector = customExtraction(b, c);
  List<double> multi = customMultiplication(baVector, bcVector);

  double dotResult = customSum(multi);
  double baSize = vectorSize(baVector);
  double bcSize = vectorSize(bcVector);

  double radi = m.acos(dotResult / (baSize * bcSize));
  double angle = (radi * 180.0 / m.pi);

  angle.abs();
  if (externalZ * direction > 0) {
    angle = 360 - angle;
  }
  return angle;
}

double customSum(List list) {
  //isEmptyError(list);
  double numb = 0;

  for (int i = 0; i < list.length; i++) {
    numb += list[i];
  }
  return numb;
}

List<double> customMultiplication(List<double> a, List<double> b) {
  List<double> base = List<double>.generate(
      a.length,
      (index) => index + 1 > a.length
          ? 1
          : a[index] * (index + 1 > b.length ? 1 : b[index]));

  return base;
}

List<double> customExtraction(List<double> a, List<double> b) {
  List<double> base = List<double>.generate(
      a.length,
      (index) => index + 1 > a.length
          ? 0
          : a[index] - (index + 1 > b.length ? 0 : b[index]));

  return base;
}

double vectorSize(List<double> vector) {
  double num = 0;
  for (int i = 0; i < vector.length; i++) {
    num += vector[i] * vector[i];
  }
  num = m.sqrt(num);
  return num;
}

double listMax(List<double> list) {
  list.sort();
  return list.last;
}

double listMin(List<double> list) {
  list.sort();
  return list.first;
}

double getDistance(PoseLandmark lmFrom, PoseLandmark lmTo) {
  double x2 = (lmFrom.x - lmTo.x) * (lmFrom.x - lmTo.x);
  double y2 = (lmFrom.y - lmTo.y) * (lmFrom.y - lmTo.y);
  return m.sqrt(x2 + y2);
}

double calculateAngle2D(List<List<double>> listXyz, {int direction = 1}) {
  /*
  this function is divided by left and right side because this function uses external product
  input : a, b, c -> landmarks with shape [x,y,z]
  direction -> int -1 or 1 (default is 1)
   -1 means Video(photo) for a person's left side and 1 means Video(photo) for a person's right side
  output : angle between vector 'ba' and 'bc' with range 0~360
  */
  List<double> a = listXyz[0].sublist(0, 2);
  List<double> b = listXyz[1].sublist(0, 2);
  List<double> c = listXyz[2].sublist(0, 2);

  double externalZ =
      (b[0] - a[0]) * (b[1] - c[1]) - (b[1] - a[1]) * (b[0] - c[0]);
  List<double> baVector = customExtraction(b, a);
  List<double> bcVector = customExtraction(b, c);
  List<double> multi = customMultiplication(baVector, bcVector);

  double dotResult = customSum(multi);
  double baSize = vectorSize(baVector);
  double bcSize = vectorSize(bcVector);

  double radi = m.acos(dotResult / (baSize * bcSize));
  double angle = (radi * 180.0 / m.pi);

  angle.abs();
  if ((externalZ * direction) > 0) {
    angle = 360 - angle;
  }
  return angle;
}

double calculateAngle2DVector(List<double> v1, List<double> v2) {
  List<double> multi = customMultiplication(v1, v2);

  double dotResult = customSum(multi);
  double v1Size = vectorSize(v1);
  double v2Size = vectorSize(v2);

  double radi = m.acos(dotResult / (v1Size * v2Size));
  double angle = (radi * 180.0 / m.pi);

  angle.abs();
  return angle;
}

bool isOutlierPushUps(List<double> angleList, int joint) {
  /*
  각도차이가 많이 나는것은 무시하는 함수
  */
  if (angleList.length < 5) {
    return false;
  }
  List<int> th = [45, 50, 30];
  int idx = angleList.length - 1;
  double diff = customSum(angleList.sublist(idx - 3, idx)) / 3 - angleList.last;
  diff.abs();
  if (diff > th[joint]) {
    return true;
  }
  return false;
}

bool isOutlierSquats(List<double> angleList, int joint) {
  /*
  각도차이가 많이 나는것은 무시하는 함수
  */
  if (angleList.length < 5) {
    return false;
  }
  List<int> th = [50, 50];
  int idx = angleList.length - 1;
  double diff = customSum(angleList.sublist(idx - 3, idx)) / 3 - angleList.last;
  diff.abs();
  if (diff > th[joint]) {
    return true;
  }
  return false;
}

bool isOutlierPullUps(List<double> angleList, int joint) {
  /*
  각도차이가 많이 나는것은 무시하는 함수
  joint는 0, 1, 2, 3 값을 가지며 각각 elbow, shoulder, hip, normY를 나타냄
  */
  if (angleList.length < 5) {
    return false;
  }
  List<int> th = [130, 130, 40, 30];
  int idx = angleList.length - 1;
  double diff = customSum(angleList.sublist(idx - 3, idx)) / 3 - angleList.last;
  diff.abs();
  if (diff > th[joint]) {
    return true;
  }
  return false;
}

List<int> sortFeedback(List<int> feedbackCounts){
  List<List<int>> tmp = <List<int>>[];
  for (int i=0; i<feedbackCounts.length; i++){
    tmp.add(<int>[feedbackCounts[i], i]);
  }
  tmp.sort((a,b) => b[0].compareTo(a[0]));
  List<int> result = <int>[];
  for(int i=0; i<tmp.length; i++){
    if (tmp[i][0] != 0){
      result.add(tmp[i][1]);
    }
  }
  return result;
}

int sumInt(List<int> li){
  int n = li.length;
  int sum = 0;
  for(int i=0; i<n; i++){
    sum += li[i];
  }
  return sum;
}