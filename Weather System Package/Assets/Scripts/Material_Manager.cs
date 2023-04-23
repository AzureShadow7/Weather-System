using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Material_Manager : MonoBehaviour
{
    [Header("Snow Materials")]
    public Material building1snowMat;
    public Material building2snowMat;
    public Material building3snowMat;

    [Header("Rain Materials")]
    public Material building1rainMat;
    public Material building2rainMat;
    public Material building3rainMat;

    [Header("Ground Mixed Materials")]
    public Material gradualsnowMat;
    public Material walkablesnowMat;
    public Material gradualrainMat;

    public GameObject[] building1;
    public GameObject[] building2;
    public GameObject[] building3;
    public GameObject ground;


    [SerializeField] MeshRenderer[] building1Renderer;
    [SerializeField] MeshRenderer[] building2Renderer;
    [SerializeField] MeshRenderer[] building3Renderer;
    public MeshRenderer groundRenderer;

    // Start is called before the first frame update
    void Start()
    {
        for (int i = 0; i < building1Renderer.Length; i++)
        {
            building1Renderer[i] = building1[i].GetComponent<MeshRenderer>();
        }

        for (int i = 0; i < building2Renderer.Length; i++)
        {
            building2Renderer[i] = building2[i].GetComponent<MeshRenderer>();
        }

        for (int i = 0; i < building3Renderer.Length; i++)
        {
            building3Renderer[i] = building3[i].GetComponent<MeshRenderer>();
        }

        groundRenderer = ground.GetComponent<MeshRenderer>();

    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void snowfall()
    {
        groundRenderer.material = gradualsnowMat;

        for (int i = 0; i < building1Renderer.Length; i++)
        {
            Debug.Log("Snowing");
            building1Renderer[i].material = building1snowMat;
        }

        for (int i = 0; i < building2Renderer.Length; i++)
        {
            building2Renderer[i].material = building2snowMat;
        }

        for (int i = 0; i < building3Renderer.Length; i++)
        {
            building3Renderer[i].material = building3snowMat;
        }

    }

    public void snowedGround()
    {
        groundRenderer.material = walkablesnowMat;
    }

    public void rainfall()
    {
        groundRenderer.material = gradualrainMat;

        for (int i = 0; i < building1Renderer.Length; i++)
        {
            Debug.Log("raining");
            building1Renderer[i].material = building1rainMat;
        }

        for (int i = 0; i < building2Renderer.Length; i++)
        {
            building2Renderer[i].material = building2rainMat;
        }

        for (int i = 0; i < building3Renderer.Length; i++)
        {
            building3Renderer[i].material = building3rainMat;
        }
    }
}
