using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class CameraShader : MonoBehaviour
{
    //[SerializeField] private Shader shader;
    [SerializeField] private Material material;

    void Awake()
    {
        //material = new Material(shader);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, material);
    }
}
