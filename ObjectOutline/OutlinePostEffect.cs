using UnityEngine;
using System.Collections;

public class OutlinePostEffect : MonoBehaviour
{
    Camera AttachedCamera;
    public Shader Post_Outline;
    public Shader DrawSimple;
    Camera TempCam;
    Material Post_Mat;

    [Range(0, 100)]
    public int width = 20;

    [Range(0, 4)]
    public float strength = 2;

    public Color outlineColor = Color.blue;

    // public RenderTexture TempRT;

    void Start()
    {
        AttachedCamera = GetComponent<Camera>();
        TempCam = new GameObject().AddComponent<Camera>();
        TempCam.enabled = false;
        Post_Mat = new Material(Post_Outline);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //set up a temporary camera
        TempCam.CopyFrom(AttachedCamera);
        TempCam.clearFlags = CameraClearFlags.Color;
        TempCam.backgroundColor = Color.black;

        //cull any layer that isn't the outline
        TempCam.cullingMask = 1 << LayerMask.NameToLayer("Outline");

        //make the temporary rendertexture
        RenderTexture TempRT = new RenderTexture(source.width, source.height, 0, RenderTextureFormat.R8);

        //put it to video memory
        TempRT.Create();

        //set the camera's target texture when rendering
        TempCam.targetTexture = TempRT;

        //render all objects this camera can render, but with our custom shader.
        TempCam.RenderWithShader(DrawSimple, "");

        Post_Mat.SetTexture("_SceneTex", source);
        Post_Mat.SetInt("_Width", width);
        Post_Mat.SetFloat("_Strength", strength);
        Post_Mat.SetColor("_OutlineColor", outlineColor);

        //copy the temporary RT to the final image
        Graphics.Blit(TempRT, destination, Post_Mat);

        //release the temporary RT
        TempRT.Release();
    }

}