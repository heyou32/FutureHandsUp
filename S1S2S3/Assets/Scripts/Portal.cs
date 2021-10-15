using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Portal : MonoBehaviour
{
   // GameObject[] players;
    GameObject testPlayer;
    public GameObject nowScene;
    public GameObject nextScene;

    public Transform startPosGrp;
    [SerializeField] List<Transform> startPos = new List<Transform>();

    private void Awake()
    {
     //   players = GameObject.FindGameObjectsWithTag("Player");
        testPlayer = GameObject.Find("XR Rig");
      
        for (int i = 0; i < startPosGrp.childCount; i++)
        {
            startPos.Add(startPosGrp.GetChild(i));
        }
    }

    public bool test;
    private void Update()
    {
        if (test)
        {
            InPortal();
            test = false;
        }
    }
    private void OnTriggerEnter(Collider other)
    {
        //InPortal();
        nowScene.SetActive(false);
        nextScene.SetActive(true);

        int r = Random.Range(0, startPos.Count);
        other.transform.parent.transform.parent.transform.parent.position = startPos[r].position; //트리거=손 오브젝트 , 포지션=XR Rig
        startPos.RemoveAt(r);
    }
    void InPortal()
    {
        nowScene.SetActive(false);
        //S 전환할 때 에니메이션 필요함
        nextScene.SetActive(true);

        int r = Random.Range(0, startPos.Count);
        testPlayer.transform.position = startPos[r].position;
        startPos.RemoveAt(r);

    }
}
