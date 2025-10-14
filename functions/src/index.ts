import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

// 60일 후 자동 삭제를 위한 스케줄러 함수
export const scheduleAccountDeletion = functions.pubsub
  .schedule('0 2 * * *') // 매일 오전 2시 실행
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    const db = admin.firestore();
    const auth = admin.auth();
    
    // 60일 전에 삭제 요청된 계정들 찾기
    const sixtyDaysAgo = new Date();
    sixtyDaysAgo.setDate(sixtyDaysAgo.getDate() - 60);
    
    const usersToDelete = await db
      .collection('user_profile')
      .where('user_delete_date', '!=', null)
      .where('user_delete_date', '<=', sixtyDaysAgo)
      .get();
    
    const batch = db.batch();
    const deletePromises: Promise<void>[] = [];
    
    for (const doc of usersToDelete.docs) {
      const userData = doc.data();
      const uid = doc.id;
      
      try {
        // 1. Firestore 데이터 삭제
        batch.delete(doc.ref);
        
        // 2. 채팅 데이터 삭제
        const chatDoc = db.collection('chatbot').doc(uid);
        batch.delete(chatDoc);
        
        // 3. 메시지 컬렉션 삭제
        const messagesSnapshot = await db
          .collection('chatbot')
          .doc(uid)
          .collection('messages')
          .get();
        
        messagesSnapshot.docs.forEach(messageDoc => {
          batch.delete(messageDoc.ref);
        });
        
        // 4. Firebase Auth에서 사용자 삭제
        deletePromises.push(auth.deleteUser(uid));
        
        console.log(`계정 삭제 예약: ${uid}`);
      } catch (error) {
        console.error(`계정 삭제 실패: ${uid}`, error);
      }
    }
    
    // Firestore 배치 삭제 실행
    await batch.commit();
    
    // Firebase Auth 삭제 실행
    await Promise.all(deletePromises);
    
    console.log(`${usersToDelete.size}개의 계정이 삭제되었습니다.`);
  });

// 계정 비활성화 시 삭제 날짜 설정
export const deactivateAccount = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', '인증이 필요합니다.');
  }
  
  const uid = context.auth.uid;
  const db = admin.firestore();
  
  // 삭제 날짜 설정 (현재 시간)
  await db.collection('user_profile').doc(uid).update({
    user_delete_date: admin.firestore.FieldValue.serverTimestamp(),
    user_delete_note: data.reason || '사용자 요청'
  });
  
  return { success: true };
});
