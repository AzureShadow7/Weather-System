using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]
public class CameraShader : MonoBehaviour
{
    [SerializeField] private Shader shader;

    public Material raymarchMaterial
    {
        get 
        { 
            if (!raymarchMat && shader)
            {
                Debug.Log("Showing shader");
                raymarchMat = new Material(shader);
                raymarchMat.hideFlags = HideFlags.HideAndDontSave;
            }
                
                return raymarchMat; 
        }
    }

    private Material raymarchMat;

    public Camera cam
    {
        get
        {
            if (!_cam)
            {
                _cam = GetComponent<Camera>();
            }
            return _cam;
        }
    }

    private Camera _cam;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!raymarchMaterial)
        {
            Graphics.Blit(source, destination);
            return;
        }

        raymarchMaterial.SetMatrix("_CamFrustum", CamFrustum(_cam));
        raymarchMaterial.SetMatrix("_CamToWorld", _cam.cameraToWorldMatrix);
        raymarchMaterial.SetVector("_CamWorldSpace", _cam.transform.position);

        RenderTexture.active = destination;
        GL.PushMatrix();
        GL.LoadOrtho();
        raymarchMaterial.SetPass(0);
        GL.Begin(GL.QUADS);

        //BL
        GL.MultiTexCoord2(0, 0.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 3.0f);

        //BR
        GL.MultiTexCoord2(0, 1.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 2.0f);

        //TR
        GL.MultiTexCoord2(0, 1.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 1.0f);

        //TL
        GL.MultiTexCoord2(0, 0.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 0.0f);

        
        GL.End();
        GL.PopMatrix();
    }

    private Matrix4x4 CamFrustum(Camera cam)
    {
        Matrix4x4 frustum = Matrix4x4.identity;
        float FOV = Mathf.Tan((cam.fieldOfView * 0.5f) * Mathf.Deg2Rad);

        Vector3 Up = Vector3.up * FOV;
        Vector3 Right = Vector3.right * FOV * cam.aspect;

        Vector3 TL = (-Vector3.forward - Right + Up);
        Vector3 TR = (-Vector3.forward + Right + Up);
        Vector3 BL = (-Vector3.forward - Right - Up);
        Vector3 BR = (-Vector3.forward + Right - Up);

        frustum.SetRow(0, TL);
        frustum.SetRow(1, TR);
        frustum.SetRow(2, BR);
        frustum.SetRow(3, BL);

        return frustum;
    }

}
