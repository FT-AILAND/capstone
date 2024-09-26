
// 페이지
import 'package:ait_project/Pages/work_detail.dart';
import 'package:ait_project/Pages/work.dart';

// 이미지랑 설명 텍스트들을 변수로 따로 빼둔 파일
import 'package:ait_project/data/back_description.dart';
import 'package:ait_project/data/chest_description.dart';
import 'package:ait_project/data/legs_description.dart';

Map<String, dynamic> muscleList = {
  'chest': workPage(
    exerciseList: chestExerciseList,
  ),
  'legs': workPage(
    exerciseList: legsExerciseList,
  ),
  'back': workPage(
    exerciseList: pullUpExerciseList,
  ),
};

Map<String, Map<String, dynamic>> chestExerciseList = {
  'Push Up': {
    'image': pushUpImageUrl,
    'nextPage': WorkDetailPage(
      workoutName: 'Push Up',
      description: pushUpDescription,
      isReadyForAI: true,
      imageUrl: pushUpImageUrl,
      korName: '푸시업',
      guide: pushUpGuide,
      shortDes: pushUpShort,
    ),
    'hashTag': pushUpTag,
  },
  'Diamond Push Up': {
    'image': diamondPushUpImageUrl,
    'nextPage': WorkDetailPage(
      workoutName: 'Diamond Push Up',
      description: diamondPushUpDescription,
      isReadyForAI: false,
      imageUrl: diamondPushUpImageUrl,
      korName: '다이아몬드 푸시업',
      guide: diamondPushUpGuide,
      shortDes: diamondPushUpShort,
    ),
    'hashTag': diamondPushUpTag,
  },
  // 'Bench Press': {
  //   'image':
  //       'https://image.freepik.com/free-photo/focused-man-doing-workout-weight-bench_329181-14155.jpg',
  //   'nextPage': WorkDetailPage(
  //   )
  // },
  // 'Barbell Curl': {
  //   'image':
  //       'https://images.pexels.com/photos/1431282/pexels-photo-1431282.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=750&w=1260',
  //   'nextPage': WorkDetailPage(
  //   )
  // },
};

Map<String, Map<String, dynamic>> legsExerciseList = {
  'Squat': {
    'image': squatImageUrl,
    'nextPage': WorkDetailPage(
      workoutName: 'Squat',
      description: squatDescription,
      isReadyForAI: true,
      imageUrl: squatImageUrl,
      korName: '스쿼트',
      guide: squatGuide,
      shortDes: squatShort,
    ),
    'hashTag': squatTag,
  },
  // 'Lunge': {
  //   'image':
  //       'https://images.pexels.com/photos/5067670/pexels-photo-5067670.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
  //   'nextPage': WorkDetailPage(
  //   ),
  // },
  // 'DeadLift': {
  //   'image':
  //       'https://images.pexels.com/photos/791763/pexels-photo-791763.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260',
  //   'nextPage': WorkDetailPage(
  //   ),
  // },
};

Map<String, Map<String, dynamic>> pullUpExerciseList = {
  'Pull Up': {
    'image': pullUpImageUrl,
    'nextPage': WorkDetailPage(
      workoutName: 'Pull Up',
      description: pullUpDescription,
      isReadyForAI: true,
      imageUrl: pullUpImageUrl,
      korName: '풀업',
      guide: pullUpGuide,
      shortDes: pullUpShort,
    ),
    'hashTag': pullUpTag,
  },
};