
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
  // 'Diamond Push Up': {
  //   'image': diamondPushUpImageUrl,
  //   'nextPage': WorkDetailPage(
  //     workoutName: 'Diamond Push Up',
  //     description: diamondPushUpDescription,
  //     isReadyForAI: false,
  //     imageUrl: diamondPushUpImageUrl,
  //     korName: '다이아몬드 푸시업',
  //     guide: diamondPushUpGuide,
  //     shortDes: diamondPushUpShort,
  //   ),
  //   'hashTag': diamondPushUpTag,
  // },
    'Bench Press': {
      'image': benchPressImageUrl,
      'nextPage': WorkDetailPage(
        workoutName: 'Bench Press',
        description: benchPressDescription,
        isReadyForAI: false,
        imageUrl: benchPressImageUrl,
        korName: '벤치프레스',
        guide: benchPressGuide,
        shortDes: benchPressShort,
      ),
      'hashTag': benchPressTag,
    },
    'Barbell Curl': {
      'image': curlsImageUrl,
      'nextPage': WorkDetailPage(
        workoutName: 'Barbell Curl',
        description: curlsDescription,
        isReadyForAI: false,
        imageUrl: curlsImageUrl,
        korName: '바벨컬',
        guide: curlsGuide,
        shortDes: curlsShort,
      ),
      'hashTag': curlsTag,
    },
    'Rowing Machine': {
      'image': rowingMachineImageUrl,
      'nextPage': WorkDetailPage(
        workoutName: 'Rowing Machine',
        description: rowingMachineDescription,
        isReadyForAI: false,
        imageUrl: rowingMachineImageUrl,
        korName: '로잉머신',
        guide: rowingMachineGuide,
        shortDes: rowingMachineShort,
      ),
      'hashTag': rowingMachineTag,
    },
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
  'Dead Lift': {
    'image': deadLiftImageUrl,
    'nextPage': WorkDetailPage(
      workoutName: 'Dead Lift',
      description: deadLiftDescription,
      isReadyForAI: false,
      imageUrl: deadLiftImageUrl,
      korName: '데드리프트',
      guide: deadLiftGuide,
      shortDes: deadLiftShort,
    ),
    'hashTag': deadLiftTag,
  },
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
  'Plank': {
    'image': plankImageUrl,
    'nextPage': WorkDetailPage(
      workoutName: 'Plank',
      description: plankDescription,
      isReadyForAI: false,
      imageUrl: plankImageUrl,
      korName: '플랭크',
      guide: plankGuide,
      shortDes: plankShort,
    ),
    'hashTag': plankTag,
  },
};